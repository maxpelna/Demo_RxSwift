//
//  AppCoordinator.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxFlow

final class AppCoordinator: Flow {

    public var root: Presentable {
        return rootWindow
    }

    private let rootWindow: UIWindow

    init(with rootWindow: UIWindow?) {
        self.rootWindow = rootWindow!
    }

    public func navigate(to step: Step) -> FlowContributors {
        return navigateToGIFList()
    }

    private func navigateToGIFList() -> FlowContributors {
        let listFlow = ListFlow()

        Flows.whenReady(flow1: listFlow) { [weak self] (root) in
            guard let self = self else { return }
            self.rootWindow.rootViewController = root
            self.rootWindow.makeKeyAndVisible()

            UIView.transition(with: self.rootWindow,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }

        return .one(flowContributor:
            FlowContributor.contribute(withNextPresentable: listFlow,
                                       withNextStepper: OneStepper(withSingleStep: AppStep.list)))
    }
}
