//
//  GIFDetailsVM.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import UIKit

protocol PGIFDetailsVM: PBaseViewModel {
    var url: URL? { get }
    var aspectRatio: CGFloat { get }
}

final class GIFDetailsVM: BaseViewModel, PGIFDetailsVM {

    private let image: ImageInfo!

    var url: URL? {
        return image.address
    }

    var aspectRatio: CGFloat {
        return CGFloat(image.aspectRatio)
    }

    init(image: ImageInfo) {
        self.image = image
    }
}
