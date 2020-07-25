//
//  APIConfig.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

public struct APIConfig {
    static let baseURL = "https://api.giphy.com/v1/gifs"

    struct APIPath {
        static let trending = "/trending"
        static let search = "/search"
    }
}
