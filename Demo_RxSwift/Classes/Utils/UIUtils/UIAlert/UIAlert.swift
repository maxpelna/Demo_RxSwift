//
//  UIAlert.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Kingfisher

extension UIViewController {
    public func showAlert(_ alertItems: Alert, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: alertItems.title,
                                      message: alertItems.message,
                                      preferredStyle: preferredStyle)

        if let buttons = alertItems.buttons {
            for button in buttons {

                let title = button.text

                if let buttonAction = button.action {
                    switch buttonAction {
                    case .clearCache:
                        let actionButton = UIAlertAction(title: title, style: .default, handler: { _ in
                            ImageCache.default.clearDiskCache()
                        })
                        alert.addAction(actionButton)
                    case .defaultAction:
                        let actionButton = UIAlertAction(title: title, style: .default, handler: nil)
                        alert.addAction(actionButton)
                    }
                }
            }
        }

        let cancelButton = UIAlertAction(title: "cancel_button".localized(), style: .cancel, handler: nil)
        alert.addAction(cancelButton)

        self.present(alert, animated: true)
    }

    public func showError(_ error: Error) {
        let alert = UIAlertController(title: "error_title".localized(),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok_button".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
