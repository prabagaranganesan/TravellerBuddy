//
//  AlertInfoView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

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
