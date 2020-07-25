//
//  Injectable.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

// MARK: APIFunctions
protocol APIFunctionsInjectable {
    static var apiFunctions: PAPIFunctions { get }
}

extension APIFunctionsInjectable {
    static var apiFunctions: PAPIFunctions {
        return DependenciesAssembler.shared.dependencies.apiFunctions()
    }
}

// MARK: NetworkSerive
protocol NetworkServiceInjectable {
    static var networkService: PNetworkService { get }
}

extension NetworkServiceInjectable {
    static var networkService: PNetworkService {
        return DependenciesAssembler.shared.dependencies.networkService()
    }
}
