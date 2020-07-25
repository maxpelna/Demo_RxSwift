//
//  Alert.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import Foundation

public class Alert {
    public var buttons: [Button]?
    public var message: String?
    public var title: String?

    init(buttons: [Button], message: String, title: String) {
        self.buttons = buttons
        self.message = message
        self.title = title
    }
}

public class Button {
    public var action: ButtonAction?
    public var text: String?

    init(action: ButtonAction, text: String) {
        self.action = action
        self.text = text
    }
}

public enum ButtonAction: String, Codable {
    case clearCache
    case defaultAction
}
