//
//  SearchResultItemCell.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 31/12/23.
//

import Foundation
import UIKit

final class SearchResultItemCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var chevronIcon: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        view.image = UIImage(systemName: "chevron.right")
        view.contentMode = .scaleAspectFit
        view.tintColor = .gray
        return view
    }()
    
    private lazy var divider: UIView = {
        let view: UIView = UIView.construct()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.contentView.addSubviews(titleLabel, subTitleLabel, chevronIcon, divider)
        applyConstraints()
        self.selectionStyle = .none
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.chevronIcon.leadingAnchor, constant: -16),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            subTitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            subTitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            subTitleLabel.trailingAnchor.constraint(equalTo: self.chevronIcon.leadingAnchor),
            
            chevronIcon.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            chevronIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }
    
    func display(viewModel: SearchResultCellViewModel) {
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
    }
}
