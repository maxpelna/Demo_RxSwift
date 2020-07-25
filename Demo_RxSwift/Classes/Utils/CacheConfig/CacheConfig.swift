//
//  CacheConfig.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

struct CacheConfig {
    private static let mbCount = 10
    static let bytesCount = 1024 * 1024

    static var imagesSize: Int {
        return mbCount * bytesCount
    }
}
