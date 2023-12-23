//
//  PlacesListCell.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation
import UIKit

struct PlacessListCellViewModel {
    let title: String
    let imagePath: String
}

final class PlacesListCell: UICollectionViewCell {
    
    private var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        return view
    }()
    
    private var descriptionStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.construct()
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = .white
        contentView.addSubviews(imageView, titleLabel, descriptionStackView)
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionStackView.topAnchor, constant: -8),
            
            descriptionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            descriptionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            descriptionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func display(viewModel: PlacesListItemUIModel?) {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title
        guard let imagePath = viewModel.imagePath, let url = URL(string: imagePath) else { return }
        imageView.setImage(with: url)
    }
}
