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
        label.font = .boldSystemFont(ofSize: 14) //TODO: import font from json so that it will be easy to switch to different font with less work
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        return view
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
        contentView.addSubviews(imageView, titleLabel)
        applyConstraints()
        applyCornerRadius()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2.2),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func applyCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 12
    }
    
    func display(viewModel: PlacesListItemUIModel?) {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title?.localizedCapitalized
        guard let imagePath = viewModel.imagePath, let url = URL(string: imagePath) else { return }
        imageView.setImage(with: url)
    }
}
