//
//  UIImageViewExtensions.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 23/12/23.
//

import Foundation
import UIKit

public let imageDownloader = ImageDownloader()
public typealias ImageDownloadCompletionClosure = (UIImage, Error?, URL?) -> Void


extension UIImageView {
    
    private struct AssociatedKey {
        static var imageURL = "places_image_url"
    }
    
    var currentImageURL: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.imageURL) as? String ?? ""
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKey.imageURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setImage(with url: URL, placeholder: UIImage? = nil, transition: ImageTransition = .none,  completed: ImageDownloadCompletionClosure? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            self?.image = placeholder
            self?.layoutIfNeeded()
        }
        
        self.currentImageURL = url.absoluteString
        
        //TODO: do we need run on main thread
        DispatchQueue.main.async {
            imageDownloader.download(with: url) { [weak self] isCache, data, error in
                DispatchQueue.main.async { () -> Void in
                    guard let self = self, self.currentImageURL == url.absoluteString else { return }
                    guard let imageData = data, let newImage = UIImage(data: imageData) else {
                        completed?(placeholder ?? UIImage(), error, url)
                        return
                    }
                    if isCache {
                        ImageTransition.none.transform(imageView: self, image: newImage)
                    } else {
                        transition.transform(imageView: self, image: newImage)
                    }
                    completed?(newImage, error, url)
                }
            }
        }
    }
}

public enum ImageTransition {
    case none
    case fade
    case custom(transition: (UIImageView, UIImage) -> Void)
    
    public func transform(imageView: UIImageView, image: UIImage) {
        switch self {
        case .none:
            imageView.image = image
        case .fade:
            UIView.transition(with: imageView, duration: 0.3, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                imageView.image = image
            }, completion: nil)
        case .custom(let transition):
            transition(imageView, image)
        }
    }
}
