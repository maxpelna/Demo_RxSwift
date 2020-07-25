//
//  GIFDetailsVC.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Kingfisher
import RxSwift
import RxCocoa

final class GIFDetailsVC: UIViewController, StoryboardBased {

    @IBOutlet private weak var closeBtn: UIButton!
    @IBOutlet private weak var shareBtn: UIButton!
    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var imageHeight: NSLayoutConstraint!
    @IBOutlet private weak var imageSideConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contrainerSideConstraint: NSLayoutConstraint!

    var viewModel: PGIFDetailsVM!
    private let bag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shareBtn.setTitle("share_button".localized(), for: .normal)
        let constraintsWidth = (imageSideConstraint.constant + contrainerSideConstraint.constant) * 2
        let newHeight = viewModel.aspectRatio * (view.bounds.width - constraintsWidth)
        imageHeight.constant = newHeight
        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.kf.indicatorType = .activity
        imageView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        imageView.kf.setImage(with: viewModel.url, options: [.transition(.fade(0.3))])
        addHandlers()
    }

    private func addHandlers() {
        closeBtn.rx.tap
            .do(onNext: { ImageDownloader.default.cancelAll() })
            .map { AppStep.list }
            .bind(to: viewModel.steps)
            .disposed(by: bag)

        shareBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let urlString = self?.viewModel.url?.absoluteString else { return }
                let activityController = UIActivityViewController(activityItems: [urlString],
                                                                  applicationActivities: nil)
                activityController.popoverPresentationController?.sourceView = self?.view
                self?.present(activityController, animated: true, completion: nil)
            }).disposed(by: bag)
    }
}
