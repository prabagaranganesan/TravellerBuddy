//
//  PlacesSectionHeaderView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 23/12/23.
//

import Foundation
import UIKit

struct SectionHeaderViewModel {
    let title: String
    let ctaName: String
}

final class PlacesSectionHeaderView: UIView {
    
    private var leftLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private var rightButton: UIButton = {
        let button: UIButton = UIButton.construct()
        button.titleLabel?.textAlignment = .right
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubviews(leftLabel, rightButton)
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            leftLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftLabel.trailingAnchor.constraint(equalTo: rightButton.trailingAnchor, constant: -12),
            
            rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            rightButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }
    
    func display(viewModel: SectionHeaderViewModel) {
        leftLabel.text = viewModel.title
        rightButton.setTitle(viewModel.ctaName, for: .normal)
    }
}
