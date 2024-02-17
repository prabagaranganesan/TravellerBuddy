//
//  AlertAction.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

struct AlertAction {
    let button: UIButton
    let displayTitle: String
    let completion: Completion?
    
    init(title: String, type: Control = .primary, completion: Completion? = nil) {
        self.completion = completion
        self.displayTitle = title
        self.button = type.button
        self.button.setTitle(title, for: .normal) //TODO: move to different method
    }
    
    init(displayTitle: String) {
        self.displayTitle = displayTitle
        self.completion = nil
        self.button = Control.primary.button
        self.button.setTitle(displayTitle, for: .normal) //TODO: move to different method
    }
}

enum Control {
    case primary
    case secondary
    case warning
    
    var button: UIButton {
        switch self {
        case .primary:
            return UIButton()
        case .secondary:
            return UIButton()
        case .warning:
            return UIButton()
        }
    }
}

typealias Completion = () -> Void
struct ActionInfo {
    let title: String
    let completion: Completion
}

struct AlertInfo {
    let info: String
    let message: String?
}
