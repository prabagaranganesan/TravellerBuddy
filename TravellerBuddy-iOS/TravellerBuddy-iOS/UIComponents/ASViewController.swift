//
//  ASViewController.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 07/04/24.
//

import UIKit

open class ASUIViewController: UIViewController, UIViewControllerTheming {
    
    public var viewBackgroundColortoken: ColorToken? {
        didSet {
            viewThemeable?.backgroundColorToken = viewBackgroundColortoken
        }
    }
    
    public private(set) var overrideTheme: Theme? {
        didSet {
            themeDidChange()
        }
    }

    private var _theme: Theme = Themes.current {
        didSet {
            guard oldValue.name != _theme.name else { return }
            themeDidChange()
        }
    }
    
    public var viewThemeable: ASUIView? {
        return self.view as? ASUIView
    }

    open var theme: Theme {
        get {
            if let overrideTheme = self.overrideTheme {
                return overrideTheme
            } else {
                return _theme
            }
        }
        set {
            guard overrideTheme == nil else { return }
            _theme = newValue
        }
    }

    override open var view: UIView! {
        willSet {
            assert(newValue?.isKind(of: ASUIView.self) ?? false, "The view must be a ASUIView")
        }
    }

    public convenience init(theme: Theme, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.theme = theme
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.inheritTheme()
        self.viewThemeable?.backgroundColorToken = theme.fillBackground
    }

    open func themeDidChange() {
        self.propagateThemeChange()
    }

    override open func didMove(toParent parent: UIViewController?) {
        guard overrideTheme == nil else {
            // Theme is already set hence refrain from inheriting from the parent.
            return
        }
        if let parent = parent as? ASUIViewController {
            self.theme = parent.theme
        }
    }

    public func applyShadow() {
        /// Using hardcoded values for to demo. Will update once get appropriate values from design team.
        let color = theme.shadowHigh.color.value(for: self.view.appearance).uiColor
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = color.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1
    }

    public func removeShadow() {
        self.navigationController?.navigationBar.layer.shadowColor = nil
        self.navigationController?.navigationBar.layer.shadowOpacity = 0
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: -3.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3
    }
}

extension UIViewControllerTheming {
    func inheritTheme() {
        guard overrideTheme == nil else {
            return
        }
        if let navVC = self.navigationController as? UIViewControllerTheming {
            self.theme = navVC.theme
        } else if let parent = self.parent as? UIViewControllerTheming {
            self.theme = parent.theme
        } else if let presentingVc = presentingViewController as? UIViewControllerTheming {
            self.theme = presentingVc.theme
        }
    }
    
    func propagateThemeChange() {
        guard isViewLoaded else { return }
        self.children.forEach {
            ($0 as? UIViewControllerTheming)?.theme = self.theme
        }
        (self.presentedViewController as? UIViewControllerTheming)?.theme = self.theme
        propagateThemeChangeToComponentViews()
    }
    
    func propagateThemeChangeToComponentViews() {
        guard isViewLoaded else { return }
        var stack = [UIView]()
        stack.append(contentsOf: self.view?.subviews ?? [])
        while stack.isEmpty == false {
            let aView = stack.removeLast()
            if let componentView = aView as? ComponentView {
                componentView.build(theme: theme)
                buildComponentTextField(view: componentView)
            } else {
                stack.append(contentsOf: aView.subviews)
            }
        }
    }
    
    private func buildComponentTextField(view: ComponentView) {
        guard let componentTextField = view as? UITextField else {
            return
        }
        if let inputAccessoryView = componentTextField.inputAccessoryView as? ComponentView {
            inputAccessoryView.build(theme: theme)
        }
        if let inputView = componentTextField.inputView as? ComponentView {
            inputView.build(theme: theme)
        }
    }
}

public protocol ComponentView: CoreViewTheming {
    func build(theme: Theme)
}

