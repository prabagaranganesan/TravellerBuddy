//
//  ASView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 07/04/24.
//

import UIKit

open class ASUIView: UIView, UIViewTheming {
    public func didChangeAppearance(to appearance: UIUserInterfaceStyle, previously: UIUserInterfaceStyle) {
        
    }
    
    public var backgroundColorToken: ColorToken? {
        didSet {
            self.backgroundColor = backgroundColorToken?.value(for: appearance).uiColor
        }
    }

    public var tintColorToken: ColorToken? {
        didSet {
            self.tintColor = self.tintColorToken?.value(for: appearance).uiColor ?? self.tintColor
        }
    }

    public var layerBorderColorToken: ColorToken? {
        didSet {
            self.layer.borderColor = self.layerBorderColorToken?.value(for: self.appearance).uiColor.cgColor
        }
    }

    public var shadowToken: ShadowToken? {
        didSet {
            // Called only when the token is set explicitly
            self.applyShadow()
        }
    }

    public func applyShadow() {
//        if let token = self.shadowToken {
//            self.layer.applyShadow(token, appearance: self.appearance)
//        } else {
//            removeShadow()
//        }
    }

    // Reverses changes made by `applyShadow`
    private func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.0
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let appearance = updatedUIUserInterfaceStyleValue(from: self.traitCollection, previous: previousTraitCollection) {
            self.didChangeAppearance(to: appearance, previously: previousTraitCollection?.userInterfaceStyle ?? .light)
        }
    }
}

public extension UIViewTheming {
    
    func didChangeAppearance(to appearance: UIUserInterfaceStyle, previously: UIUserInterfaceStyle) {
        didChangeAppearanceDefault(to: appearance, previously: previously)
    }
}

public extension CoreViewTheming {

    func updatedUIUserInterfaceStyleValue(from current: UITraitCollection, previous: UITraitCollection?) -> UIUserInterfaceStyle? {
        guard UIUserInterfaceStyle.overridden == nil else {
            return .overridden
        }

        guard let previous else {
            return nil
        }

        if current.userInterfaceStyle != previous.userInterfaceStyle {
            return current.userInterfaceStyle
        }

        if #available(iOS 13.0, *), current.accessibilityContrast != previous.accessibilityContrast {
            return current.userInterfaceStyle
        }
        return nil
    }
}


extension UIUserInterfaceStyle {
    
    static var overridden: UIUserInterfaceStyle? {
        var appearance: UIUserInterfaceStyle?
        if let alohaWindow = UIApplication.currentActiveWindow as? ASWindow,
           let overriddenAppearance = alohaWindow.overridenAppearance {
            appearance = overriddenAppearance
        } else if let preferredAppearance = ASFrameWork.shared.preferredAppearanceProvider?() {
            appearance = preferredAppearance
        }
        if appearance == .light || appearance == .dark {
            return appearance
        } else {
            return nil
        }
    }

    public static var current: UIUserInterfaceStyle {
        overridden ?? UIScreen.main.traitCollection.userInterfaceStyle
    }
}

public extension UIApplication {
    static var currentActiveWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let foregroundWindowScene = self.shared.connectedScenes.first(where: { $0.isKind(of: UIWindowScene.self) && $0.activationState == .foregroundActive }) as? UIWindowScene
            return foregroundWindowScene?.windows.first(where: { $0.isKeyWindow })
        } else {
            // Deprecated in iOS 15
            return self.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
}
