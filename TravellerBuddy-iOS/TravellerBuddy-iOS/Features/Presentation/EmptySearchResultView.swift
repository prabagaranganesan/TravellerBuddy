//
//  EmptySearchResultView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 31/12/23.
//

import Foundation
import UIKit

struct EmptySearchViewModel {
    let title: String
    let message: String
}

final class SearchEmptyResultView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view: UIStackView = UIStackView.construct()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [titleLabel, descriptionLabel].forEach { verticalStackView.addArrangedSubview($0) }
        self.addSubview(verticalStackView)
        applyConstraints()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    
    func displayData(viewModel: EmptySearchViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.message
    }
}
