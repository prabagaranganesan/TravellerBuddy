//
//  Card.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

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
        addCornerRadius()
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
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
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
    
    private func addCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor.gray.cgColor
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
            view.backgroundColor = UIColor.black.withAlphaComponent(0.6)

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
