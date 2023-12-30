//
//  UIViewExtensions.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation
import UIKit

extension UIView {
    @inline(__always) static func construct<T>(applyAttributes: ((T) -> Void)? = nil) -> T where T: UIView {
        let uiComponent = T(frame: .zero)
        uiComponent.translatesAutoresizingMaskIntoConstraints = false
        applyAttributes?(uiComponent)
        return uiComponent
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

public extension UICollectionViewCell {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UITableViewCell {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

