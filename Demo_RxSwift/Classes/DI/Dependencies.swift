//
//  Dependencies.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

protocol PDependencies {
    func apiFunctions() -> PAPIFunctions
    func networkService() -> PNetworkService
}

public final class DependenciesAssembler {
    static let shared = DependenciesAssembler()
    private(set) var dependencies: PDependencies!

    static func set(dependencies: PDependencies) {
        self.shared.dependencies = dependencies

        _ = dependencies.apiFunctions()
        _ = dependencies.networkService()
    }
}

public final class Dependencies: PDependencies {
    private var container = [String: Any]()

    func apiFunctions() -> PAPIFunctions {
        return resolve { APIFunctions() }
    }

    func networkService() -> PNetworkService {
        return resolve { NetworkService() }
    }

    private func resolve<T>(_ resolver: () -> T) -> T {
        let key = String(describing: T.self)
        guard let service = container[key] as? T else {
            let service = resolver()
            let key = String(describing: T.self)
            self.register(key: key, service: service)
            return service
        }
        return service
    }

    private func register(key: String, service: Any) {
        container[key] = service
    }
}
