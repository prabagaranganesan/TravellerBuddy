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
    
    func snapShot() -> UIImage? {

        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {

            self.layer.render(in: context)
            let screengrab = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            image = screengrab
        }

        return image
    }
    
    func snapShotView() -> UIImageView {
        let snap = self.snapShot()
        let snapView = UIImageView(image: snap)
        snapView.frame = self.convert(self.bounds, to: nil)
        return snapView
    }
    
    func roundCorners(with radius: CGFloat = 5) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
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
