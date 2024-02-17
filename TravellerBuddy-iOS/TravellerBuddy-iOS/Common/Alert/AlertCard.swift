//
//  AlertCard.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

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
