//
//  APIFuntions.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxSwift

protocol PAPIFunctions {
    func trending(limit: Int, loadCount: Int) -> Observable<ImagesData>
    func search(with text: String, limit: Int, loadCount: Int) -> Observable<ImagesData>
}

final class APIFunctions: PAPIFunctions {
    func trending(limit: Int, loadCount: Int) -> Observable<ImagesData> {
        let path = APIConfig.APIPath.trending
        let params: Params = ["limit": String(limit), "offset": String(loadCount)]
        let route = APIRoute(path: path, params: params)
        return APIRequest(route: route).request()
    }

    func search(with text: String, limit: Int, loadCount: Int) -> Observable<ImagesData> {
        let path = APIConfig.APIPath.search
        let params: Params = ["limit": String(limit), "offset": String(loadCount), "q": text]
        let route = APIRoute(path: path, params: params)
        return APIRequest(route: route).request()
    }
}
