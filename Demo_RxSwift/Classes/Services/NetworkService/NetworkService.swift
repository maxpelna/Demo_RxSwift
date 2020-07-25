//
//  NetworkService.swift
//  Demo_RxSwift
//
//  Created by Maksims Pelna on 25/07/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxSwift
import RxCocoa
import Reachability

protocol PNetworkService {
    var reachable: BehaviorRelay<Bool> { get }
    var didBecomeReachable: PublishRelay<Void> { get }
}

final class NetworkService: PNetworkService {
    private let bag = DisposeBag()
    private let reachability = try? Reachability()

    let reachable = BehaviorRelay<Bool>(value: true)
    let didBecomeReachable = PublishRelay<Void>()

    init() {
        addHandlers()
    }

    private func addHandlers() {
        reachable.distinctUntilChanged()
            .compactMap { $0 ? () : nil }
            .bind(to: didBecomeReachable)
            .disposed(by: bag)

        reachable.accept(reachability?.connection != .unavailable)

        let changeCallback: (Reachability) -> Void = { [weak self] r in
            let hasConnection = r.connection != .unavailable
            self?.reachable.accept(hasConnection)
        }

        reachability?.whenReachable = changeCallback
        reachability?.whenUnreachable = changeCallback

        do {
            try reachability?.startNotifier()
        } catch { print("Unable to start notifier") }
    }
}
