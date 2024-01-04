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

protocol PlacesListHeaderTapDelegate: AnyObject {
    func rightCTATapped()
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
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private weak var tapDelegate: PlacesListHeaderTapDelegate?
    
    init(tapDelegate: PlacesListHeaderTapDelegate?) {
        self.tapDelegate = tapDelegate
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubviews(leftLabel, rightButton)
        applyConstraints()
        rightButton.addTarget(self, action: #selector(rightCTATapped), for: .touchUpInside)
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            leftLabel.topAnchor.constraint(equalTo: self.topAnchor),
            leftLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            leftLabel.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -12),
            
            rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            rightButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }
    
    @objc
    private func rightCTATapped() {
        tapDelegate?.rightCTATapped()
    }
    
    func display(viewModel: SectionHeaderViewModel) {
        leftLabel.text = viewModel.title
        rightButton.setTitle(viewModel.ctaName, for: .normal)
    }
}
