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


class AlertCardInfoView: UIView {
    var verticalStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.construct()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    var buttonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.construct()
        stackView.axis = .horizontal
        return stackView
    }()
    
    var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    var messageLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    let buttons: [UIButton] = []
    
    init(info: AlertInfo, actions: [AlertAction]?) {
        super.init(frame: .zero)
        setupView()
        displayData(info: info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        buttons.forEach { buttonStackView.addArrangedSubview($0) }
        [titleLabel, messageLabel, buttonStackView].forEach({ verticalStackView.addArrangedSubview($0) })
        self.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
        ])
    }
    
    private func displayData(info: AlertInfo) {
        titleLabel.text = info.info
        messageLabel.text = info.message
    }
}

class AlertCard: Card {
    let info: AlertInfo
    let actions: [AlertAction]
    let buttons: [UIButton]?
    
    
    init(info: AlertInfo, actions: [AlertAction]?, buttons: [UIButton]? = nil, isDimissable: Bool = true) {
        self.info = info
        self.buttons = buttons
        
        if let allActions = actions, !allActions.isEmpty {
            self.actions = allActions
        } else {
            let defaultAction = AlertAction(displayTitle: "OK, GOT IT")
            self.actions = [defaultAction]
        }
        super.init(frame: .zero, dismissable: isDimissable)
        let alertInfoCardView = AlertCardInfoView(info: info, actions: actions)
        contentView?.addSubview(alertInfoCardView)
        guard let contentView = contentView else { return }
        NSLayoutConstraint.activate([
            alertInfoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            alertInfoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            alertInfoCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            alertInfoCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        self.addCrossButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func card(for type: AlertType, isDismissable: Bool = true) -> AlertCard? {
        guard let info = type.alertInfo else { return nil }
        var actions: [AlertAction] = []
        
        func defaultActionHandling(action: ActionInfo?, buttonType: Control = .primary) {
            let buttonTitle = buttonTitleForActionInfo(action: action)
            let action = AlertAction(title: buttonTitle, type: buttonType, completion: action?.completion)
            actions.append(action)
        }
        
        switch type {
        case .noInternetRetry:
            let action = AlertAction(title: "Settings", type: .primary, completion: {
                
            })
            actions.append(action)
        case .serverDown(let actionInfo):
            defaultActionHandling(action: actionInfo)
        }
        if actions.count == 0 {
            let btnTitle = self.buttonTitleForActionInfo(action: nil)
            let defaultAction = AlertAction(title: btnTitle, type: .primary, completion: nil)
            actions.append(defaultAction)
        }
        
        let card = AlertCard(info: info, actions: actions, isDimissable: isDismissable)
        return card
    }
    
    
    
    class func buttonTitleForActionInfo(action: ActionInfo?) -> String {
        var btnTitle: String
        if let actionTitle = action?.title {
            btnTitle = actionTitle
        } else {
            btnTitle = "Ok, Got it"
        }
        return btnTitle
    }
}

class Card: UIView {
    var actualViewHeight: CGFloat = 100
    private weak var topConstraint: NSLayoutConstraint?
    private weak var heightConstraint: NSLayoutConstraint?
    private weak var contentHieghtConstraint: NSLayoutConstraint?
    private weak var bottomConstraint: NSLayoutConstraint?
    private weak var presentedVC: UIViewController?
    let isDismissible: Bool
    var userDismissAction: Completion?
    var initialStartYPos: CGFloat = 0
    weak var animationContentView: UIView?
    static let bottomDeadHeight: CGFloat = 40
    static let cardShadowHeight: CGFloat = 12
    private var contentTopGap: CGFloat = 40
    private var crossButton: UIButton?
    private var contentBottomGap: CGFloat = 0
    
    var contentView: UIView?
    
    private let shadowImageView: UIImageView = {
        let shadowImageV = UIImageView(frame: CGRect.zero)
        shadowImageV.translatesAutoresizingMaskIntoConstraints = false
        return shadowImageV
    }()

    
    init(frame: CGRect, dismissable: Bool) {
        self.isDismissible = dismissable
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialSetup() {
        self.backgroundColor = .clear
        let panGest = UIPanGestureRecognizer(target: self, action: #selector(self.viewPanned(gesture:)))
        panGest.minimumNumberOfTouches = 1
        panGest.maximumNumberOfTouches = 1
        panGest.delegate = self
        self.addGestureRecognizer(panGest)
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        self.contentBottomGap = 16 + Card.bottomDeadHeight
        self.contentView = contentView
        contentTopGap = 28
        build()
    }
    
    func addCrossButton() {
        if self.isDismissible {
            self.accessibilityViewIsModal = true
            let button = UIButton()
            button.addTarget(self, action: #selector(self.closeClicked(button:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage.init(systemName: "multiply.circle.fill")
            button.setImage(image, for: .normal)
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.tintColor = .red
            self.contentView?.addSubview(button)
            guard let contentView = contentView else { return }
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                button.heightAnchor.constraint(equalToConstant: 32),
                button.widthAnchor.constraint(equalToConstant: 32)
            ])

            let topGap = (Card.cardShadowHeight)
            
            contentTopGap = topGap + 40 + 8
            self.crossButton = button
            
            if let cross = self.crossButton {
                self.bringSubviewToFront(cross)
            }
        }
    }
    
    func closedByUser() {
        if self.isDismissible {
            if let block = self.userDismissAction {
                block()
            }

            self.dismiss(animated: true)
        }
    }
    
    func dismiss(animated: Bool) {
        
    }
    
    @objc open func closeClicked(button: UIButton) {
        self.closedByUser()
    }
    
    public func build() {
        let image = shadowForCardTop()
        self.shadowImageView.image = image
        self.crossButton?.tintColor = .gray
        self.backgroundColor = .white
    }
    
    private func shadowForCardTop() -> UIImage? {
        let radius: CGFloat = 6
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        container.backgroundColor = .clear
        
        let view = UIView(frame: CGRect(x: 0, y: radius * 2, width: UIScreen.main.bounds.width, height: (30 + (radius * 2))))
        view.clipsToBounds = false
        view.layer.cornerRadius = 10
        view.layer.shadowRadius = radius
        view.layer.shadowOpacity = 0.6
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        container.addSubview(view)
        
        let image = container.snapShot()
        let resized = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 25, left: 20, bottom: 2, right: 20),
                                            resizingMode: UIImage.ResizingMode.stretch)
        
        return resized
    }
    
    func showFromVC(_ fromVC: UIViewController, animated: Bool, completion: (() -> Void)?) {
        let showFromVC = {
            let viewController = UIViewController()
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
                viewController.modalPresentationStyle = .overFullScreen
            } else {
                viewController.modalPresentationStyle = .overCurrentContext
            }
            
            viewController.view.backgroundColor = UIColor.clear
            fromVC.present(viewController, animated: animated) {
                self.showFromVC(fromVC, animated: animated, completion: completion)
            }
        }
        
        if Thread.isMainThread {
            showFromVC()
        } else {
            DispatchQueue.main.async {
                showFromVC()
            }
        }
    }
    
    func showFromView(fromView: UIView?, animated: Bool, completion: Completion? = nil) {
        guard let view = fromView, self.superview != view else { return }
        let showFromView = {
            self.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: self.actualViewHeight)
            self.layoutIfNeeded()
            self.translatesAutoresizingMaskIntoConstraints = false
            guard let contentView = self.contentView else { return }
            
            self.addSubview(contentView)
            view.addSubview(self)
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            
            self.heightConstraint = self.heightAnchor.constraint(equalToConstant: contentView.bounds.height)
            self.heightConstraint?.isActive = true
        }
        
       
        showFromView()
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            view.layoutIfNeeded()
        })
        
    }
    
    private func setTop(top: NSLayoutConstraint, height: NSLayoutConstraint) {
        
    }
}


extension Card: UIGestureRecognizerDelegate {
    @objc func viewPanned(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: nil)
        switch gesture.state {
        case .began:
            self.initialStartYPos = location.y
            
            let displayedContentFrame = self.animationViewInitialFrame()
            animationContentView?.removeFromSuperview()
            if let snapV = self.resizableSnapshotView(from: displayedContentFrame, afterScreenUpdates: false, withCapInsets: .zero) {
                snapV.isUserInteractionEnabled = false
                snapV.clipsToBounds = false
                snapV.frame = displayedContentFrame
                self.addSubview(snapV)
                animationContentView = snapV
            }
        case .changed:
            guard let animationView = animationContentView else { return }
            let changedValue = (self.initialStartYPos - location.y)
            let newHeight = (self.actualViewHeight + changedValue)
            let toChange: CGFloat = self.sqrtValueForHeight(height: newHeight, threshold: self.actualViewHeight)

            var frame = animationView.frame
            frame.size.height = toChange
            animationView.frame = frame
        default:
            self.settleDown(animated: true)
        }
    }
    
    func settleDown(animated: Bool) {
        
        self.superview?.layoutIfNeeded()
        
//        self.changeConstraintsForHeight(height: self.acctualViewHeight)
//        if animated {
//            UIView.Animation.defaultAnimation(animation: {
//                self.animationContentView?.frame = self.animationViewInitialFrame()
//                self.superview?.layoutIfNeeded()
//            }) { (_) in
//                self.animationContentView?.removeFromSuperview()
//            }
//        } else {
//            self.animationContentView?.removeFromSuperview()
//        }
    }
    
    
    func sqrtValueForHeight(height: CGFloat, threshold: CGFloat) -> CGFloat {
        
        var retValue: CGFloat
        if height > threshold {
            retValue = (threshold + sqrt(height - threshold))
        } else {
            retValue = (threshold - sqrt(threshold - height))
        }
        
        return  retValue
    }
    
    func animationViewInitialFrame() -> CGRect {
        let initial = CGRect(x: 0, y: Card.cardShadowHeight + 10, width: self.frame.width, height: actualViewHeight)
        return initial
    }
}

public extension UIView {
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
