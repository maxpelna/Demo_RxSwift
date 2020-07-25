//
//  GIFListVM.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa

import Localize_Swift
import Kingfisher

protocol PGIFListVM: PBaseViewModel {
    var gifImages: BehaviorRelay<[GIFData]> { get }
    var gifsCount: Int { get }

    var showLabelTrigger: Driver<Bool> { get }
    var loadedAllImages: Driver<Bool> { get }

    var cellSelectionTrigger: PublishRelay<(IndexPath, CGRect)> { get }
    var searchCancelButtonTrigger: PublishRelay<Void> { get }
    var searchTextTrigger: PublishRelay<String?> { get }
    var clearCacheButtonTrigger: PublishRelay<Void> { get }
    var refreshControlTrigger: PublishRelay<String?> { get }
    var loadMoreTrigger: PublishRelay<String?> { get }

    func showAlert()
}

final class GIFListVM: BaseViewModel, PGIFListVM, APIFunctionsInjectable {

    let gifImages = BehaviorRelay<[GIFData]>(value: [])

    private let _showLabelTrigger = PublishRelay<Bool>()
    var showLabelTrigger: Driver<Bool> {
        return _showLabelTrigger.asDriver(onErrorJustReturn: false)
    }

    private let _loadedAllImages = BehaviorRelay<Bool>(value: false)
    var loadedAllImages: Driver<Bool> {
        return _loadedAllImages.asDriver()
    }

    let cellSelectionTrigger = PublishRelay<(IndexPath, CGRect)>()
    let searchCancelButtonTrigger = PublishRelay<Void>()
    let searchTextTrigger = PublishRelay<String?>()
    let clearCacheButtonTrigger = PublishRelay<Void>()
    let refreshControlTrigger = PublishRelay<String?>()
    let loadMoreTrigger = PublishRelay<String?>()

    private var isRefreshing = false
    private var isSearching = false
    private let diskCacheSize = BehaviorRelay<Int>(value: 0)

    private let limit = 25
    private let onePageSize = 25
    private var currentOffset = 0

    var gifsCount: Int {
        return gifImages.value.count
    }

    override init() {
        super.init()
        addHandlers()
        addAlertHandler()
        showTrending()
    }

    // MARK: - Handlers -
    private func addHandlers() {
        searchCancelButtonTrigger
            .subscribe(onNext: { [weak self] _ in
                guard self?.isSearching == true else { return }
                self?.currentOffset = 0
                self?.gifImages.accept([])
                self?._loadedAllImages.accept(false)
                self?.showTrending()
            }).disposed(by: bag)

        searchTextTrigger
            .subscribe(onNext: { [weak self] text in
                self?.currentOffset = 0
                self?.gifImages.accept([])
                self?._loadedAllImages.accept(false)
                guard text?.isEmpty == false else {
                    self?.showTrending()
                    return
                }
                ImageDownloader.default.cancelAll()
                self?.searchGif(text)
            }).disposed(by: bag)

        refreshControlTrigger
            .subscribe(onNext: { [weak self] searchBarText in
                self?.currentOffset = 0
                self?.isRefreshing = true
                self?._loadedAllImages.accept(false)
                self?.isSearching == true ? self?.searchGif(searchBarText) : self?.showTrending()
            }).disposed(by: bag)

        loadMoreTrigger
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                ImageDownloader.default.cancelAll()
                self.currentOffset += self.onePageSize
                self.isSearching ? self.searchGif(text) : self.showTrending()
            }).disposed(by: bag)

        cellSelectionTrigger
            .compactMap { [weak self] index, frame in
                guard let self = self else { return nil }
                let gifImage = self.gifImages.value[index.row]
                return AppStep.fullScreen(gifImage.images.original, frame)
            }
            .bind(to: steps)
            .disposed(by: bag)
    }

    // MARK: - API Calls -
    private func showTrending() {
        isSearching = false
        isLoading.accept(true)
        type(of: self).apiFunctions
            .trending(limit: limit, loadCount: currentOffset)
            .observeOn(MainScheduler.asyncInstance)
            .asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .error(let error):
                    self?.error.accept(error)
                case .next(let images):
                    self?.addImages(images)
                case .completed:
                    self?.isLoading.accept(false)
                }
            }).disposed(by: bag)
    }

    private func searchGif(_ text: String?) {
        guard let text = text else { return }
        isSearching = true
        isLoading.accept(true)
        type(of: self).apiFunctions
            .search(with: text, limit: limit, loadCount: currentOffset)
            .observeOn(MainScheduler.asyncInstance)
            .asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .error(let error):
                    self?.error.accept(error)
                case .next(let images):
                    if images.data.isEmpty { self?._showLabelTrigger.accept(true) }
                    self?.addImages(images)
                case .completed:
                    self?.isLoading.accept(false)
                }
            }).disposed(by: bag)
    }

    private func addImages(_ images: ImagesData) {
        _showLabelTrigger.accept(images.data.isEmpty)
        var allImages = gifImages.value

        if isRefreshing {
            isRefreshing = false
            guard let firstImage = images.data.first else { return }
            if !allImages.contains(firstImage) {
                gifImages.accept(images.data)
            }
            return
        }

        guard !Set(images.data).isSubset(of: Set(allImages)) else {
            _loadedAllImages.accept(true)
            return
        }
        _loadedAllImages.accept(false)

        allImages.append(contentsOf: images.data)
        gifImages.accept(allImages)
    }
}

// MARK: - Alerts -
extension GIFListVM {
    private func getDiskCacheSize() {
        ImageCache.default.calculateDiskStorageSize { [weak self] result in
            switch result {
            case .success(let size):
                self?.diskCacheSize.accept(Int(size) / CacheConfig.bytesCount)
            case .failure:
                self?.diskCacheSize.accept(0)
            }
        }
    }

    private var clearCacheAlert: Alert {
        let btn = Button(action: .clearCache, text: "clear_button".localized())
        let alert = Alert(buttons: [btn],
                          message: "clear_description".localizedFormat("\(diskCacheSize.value)"),
                          title: "clear_title".localized())
        return alert
    }

    private var chillAlert: Alert {
        return Alert(buttons: [],
                     message: "chill_description".localized(),
                     title: "chill_title".localized())
    }

    private func addAlertHandler() {
        diskCacheSize
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let alertToShow = self.diskCacheSize.value <= 0 ? self.chillAlert : self.clearCacheAlert
                let style: UIAlertController.Style = self.diskCacheSize.value <= 0 ? .alert : .actionSheet
                self.steps.accept(AppStep.alert(alertToShow, style))
            }).disposed(by: bag)
    }

    func showAlert() {
        getDiskCacheSize()
    }
}
