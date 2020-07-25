//
//  GIFCell.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Kingfisher

final class GIFCell: UICollectionViewCell, Reusable {

    @IBOutlet private weak var imageView: UIImageView!

    private let options: [KingfisherOptionsInfoItem] = [.scaleFactor(UIScreen.main.scale/2)]

    func configure(url: URL?) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: options)
    }
}
