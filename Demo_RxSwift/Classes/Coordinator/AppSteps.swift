//
//  AppSteps.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import RxFlow

enum AppStep: Step {
    case list
    case fullScreen(ImageInfo, CGRect)
    case alert(Alert, UIAlertController.Style)
}
