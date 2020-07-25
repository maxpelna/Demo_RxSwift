//
//  ListFlow.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxFlow

final class ListFlow: Flow {

    public var root: Presentable {
        return giftListVC
    }

    private var selectedImageFrame: CGRect?
    private var aspectRatio: Double?

    private lazy var windowFrame: CGRect = {
        return giftListVC.view.frame
    }()

    private let gifListVM = GIFListVM()
    private lazy var giftListVC: UINavigationController = {
        let controller = GIFListVC.instantiate()
        controller.viewModel = gifListVM
        return UINavigationController(rootViewController: controller)
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .list:
            return list()
        case .fullScreen(let image, let cellFrame):
            return gifDetails(image: image, from: cellFrame)
        case .alert(let alert, let preferredStyle):
            giftListVC.showAlert(alert, preferredStyle: preferredStyle)
            return .none
        }
    }

    private func list() -> FlowContributors {
        if let selectedImageFrame = selectedImageFrame, let aspectRatio = aspectRatio {
            giftListVC.dismiss(animated: false, completion: nil)
            giftListVC.view.collapse(to: selectedImageFrame,
                                     windowFrame: windowFrame,
                                     aspRatio: aspectRatio)
        }
        return .one(flowContributor: FlowContributor.contribute(withNextPresentable: root, withNextStepper: gifListVM))
    }

    private func gifDetails(image: ImageInfo, from cellFrame: CGRect) -> FlowContributors {
        let vc = GIFDetailsVC.instantiate()
        let vm = GIFDetailsVM(image: image)
        vc.viewModel = vm

        selectedImageFrame = cellFrame
        aspectRatio = image.aspectRatio

        giftListVC.view.expand(from: cellFrame,
                               windowFrame: windowFrame,
                               aspRatio: image.aspectRatio,
                               completionHandler: { [weak self] in
            self?.giftListVC.present(vc, animated: false, completion: nil)
        })
        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vm))
    }
}
