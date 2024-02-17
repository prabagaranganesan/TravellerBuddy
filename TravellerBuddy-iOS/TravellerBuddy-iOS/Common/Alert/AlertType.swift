//
//  Toast.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 01/02/24.
//

import Foundation
import UIKit

enum AlertType {
    case noInternetRetry
    case serverDown(ActionInfo?)
    
    var alertInfo: AlertInfo? {
        var title: String?
        var message: String?
        
        switch self {
        case .noInternetRetry:
            title = "You seem to be offline"
            message = "Check your Wi-Fi connection or cellular data and try again."
        case .serverDown:
            title = "Oops, something went wrong"
            message = "Don’t worry, we’re fixing this. We’ll be back for you soon!"
        }
        
        if let title = title {
            return AlertInfo(info: title, message: message)
        }
        return nil
    }
}
