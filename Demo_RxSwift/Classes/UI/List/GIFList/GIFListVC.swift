//
//  GIFListVC.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxCocoa
import RxSwift
import Reachability

final class GIFListVC: UIViewController, StoryboardBased, NetworkServiceInjectable {

    @IBOutlet private weak var noResultsLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)

    var viewModel: PGIFListVM!
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureSearchBar()
        setupCollectionViewLayout()
        configureCollectionView()

        addCollectionViewHandlers()
        addSearchBarHandlers()
        addHandlers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Handlers -
    private func addCollectionViewHandlers() {
        viewModel.gifImages
            .asDriver()
            .drive(collectionView.rx.items(cellIdentifier: GIFCell.reuseIdentifier,
                                           cellType: GIFCell.self)) { _, data, cell in
                cell.configure(url: data.images.downsized.address)
            }.disposed(by: bag)

        collectionView.rx.itemSelected
            .do(onNext: { [weak self] _ in self?.searchController.searchBar.endEditing(true) })
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .compactMap { [weak self] indexPath in
                guard let self = self else { return nil }
                let theAttributes = self.collectionView.layoutAttributesForItem(at: indexPath)
                guard let frame = theAttributes?.frame else { return nil }
                let cellFrameInSuperview = self.collectionView.convert(frame, to: self.collectionView.superview)
                return (indexPath, cellFrameInSuperview)
            }
            .bind(to: viewModel.cellSelectionTrigger)
            .disposed(by: bag)

        // MARK: Pagination
        // Had to split the logic due to an error:
        // 'The compiler is unable to type-check this expression in reasonable time;
        // try breaking up the expression into distinct sub-expressions'
        let canLoadMore = PublishRelay<(Int, Int)>()
        collectionView.rx.willDisplayCell
            .withLatestFrom(Observable.combineLatest(viewModel.isLoading,
                                                     viewModel.loadedAllImages.asObservable())) { ($0, $1) }
            .filter { !$1.0 && !$1.1 }
            .map { $0.0.1.row }
            .compactMap { [weak self] row in (self?.viewModel.gifsCount ?? 0, row) }
            .bind(to: canLoadMore)
            .disposed(by: bag)

        canLoadMore
            .filter { $0-1 == $1 }
            .map { [weak self] _ in self?.searchController.searchBar.text }
            .bind(to: viewModel.loadMoreTrigger)
            .disposed(by: bag)
    }

    private func addSearchBarHandlers() {
        searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchTextTrigger)
            .disposed(by: bag)

        searchController.searchBar.rx.cancelButtonClicked
            .bind(to: viewModel.searchCancelButtonTrigger)
            .disposed(by: bag)
    }

    private func addHandlers() {
        viewModel.showLabelTrigger
            .map { !$0 }
            .drive(noResultsLabel.rx.isHidden)
            .disposed(by: bag)

        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(searchController.searchBar.rx.text)
            .bind(to: viewModel.refreshControlTrigger)
            .disposed(by: bag)

        viewModel.isLoading
            .asDriver()
            .compactMap { !$0 ? false : nil }
            .delay(.milliseconds(500))
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: bag)

        viewModel.error
            .subscribe(onNext: { [weak self] in self?.showError($0) })
            .disposed(by: bag)

        type(of: self).networkService
            .didBecomeReachable
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: bag)
    }

    // MARK: - UI -
    private func configureNavBar() {
        title = "list_title".localized()
        navigationItem.searchController = searchController

        let navBar = navigationController?.navigationBar
        navBar?.prefersLargeTitles = true
        navBar?.barStyle = .blackTranslucent
        navBar?.tintColor = .white

        let clearImg = UIImage.clearIcon
        let clearBtn = UIBarButtonItem(image: clearImg, style: .plain, target: self, action: #selector(showClearAlert))
        navigationItem.rightBarButtonItem = clearBtn
    }

    private func configureSearchBar() {
        definesPresentationContext = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "searchbar_text".localized()
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.sizeToFit()
    }

    private func configureCollectionView() {
        collectionView.refreshControl = refreshControl
    }

    @objc private func showClearAlert() {
        viewModel.showAlert()
    }

    private let layout: BaseLayout = PinterestLayout()
    private func setupCollectionViewLayout() {
        layout.delegate = self
        layout.cellsPadding = ItemsPadding(horizontal: 1, vertical: 1)
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
}

// MARK: - Pinterest layout delegate -
extension GIFListVC: LayoutDelegate {
    func cellSize(indexPath: IndexPath) -> CGSize {
        let image = viewModel.gifImages.value[indexPath.row]
        return CGSize(width: image.images.downsized.w, height: image.images.downsized.h)
    }
}
