//
//  AppDelegate.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxCocoa
import RxSwift
import RxFlow
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var appCoordinator: AppCoordinator!
    private var coordinator: FlowCoordinator?

    private let bag = DisposeBag()

    // swiftlint:disable line_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DependenciesAssembler.set(dependencies: Dependencies())

        window = UIWindow()
        appCoordinator = AppCoordinator(with: window)

        coordinator = FlowCoordinator()
        let stepper = OneStepper(withSingleStep: AppStep.list)
        coordinator?.coordinate(flow: appCoordinator, with: stepper)

        ImageCache.default.memoryStorage.config.totalCostLimit = CacheConfig.imagesSize

        return true
    }
}
