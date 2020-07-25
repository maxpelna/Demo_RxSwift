//
//  StoryboardBased.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

//=====================================================
// taken from:
// https://github.com/AliSoftware/Reusable
//=====================================================

import UIKit

public protocol StoryboardBased: class {
    static var sceneStoryboard: UIStoryboard { get }
}

public extension StoryboardBased {
    static var sceneStoryboard: UIStoryboard {
        return UIStoryboard(name: String(describing: self), bundle: Bundle(for: self))
    }
}

public extension StoryboardBased where Self: UIViewController {
    static func instantiate() -> Self {
        let viewController = sceneStoryboard.instantiateInitialViewController()
        guard let typedViewController = viewController as? Self else {
            fatalError("The initialViewController of '\(sceneStoryboard)' is not of class '\(self)'")
        }
        return typedViewController
    }
}
