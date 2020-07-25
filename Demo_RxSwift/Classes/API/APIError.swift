//
//  APIError.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

public enum APIError: LocalizedError {
    case error(code: Int, reason: String)
    case unknown
    case invalidURL(url: String)

    public var errorDescription: String? {
        switch self {
        case .error(code: _, reason: let reason):
            return reason
        case .unknown:
            return "Unknown error"
        case .invalidURL(url: let url):
            return "Invalid URL - \(url)"
        }
    }
}
