//
//  PlacesFeedCell.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

final class PlacesFeedCell: UITableViewCell {
    private var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.font = .boldSystemFont(ofSize: 14) //TODO: import font from json so that it will be easy to switch to different font with less work
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var imageBanner: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = .white
        contentView.addSubviews(imageBanner, titleLabel)
        applyConstraints()
        applyCornerRadius()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            imageBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageBanner.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageBanner.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            imageBanner.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func showShimmer() {
        imageBanner.beginShimmer(shape: .rectangle)
        titleLabel.beginShimmer(shape: .rectangle)
    }
    
    private func hideShimmer() {
        imageBanner.endShimmer()
        titleLabel.endShimmer()
    }
    
    private func applyCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        
        self.imageBanner.clipsToBounds = true
        self.imageBanner.layer.cornerRadius = 12
    }
    
    func display(viewModel: PlacesListItemUIModel?) {
        guard let viewModel = viewModel else {
            showShimmer()
            return
        }
        hideShimmer()
        titleLabel.text = viewModel.title?.localizedCapitalized
        guard let imagePath = viewModel.imagePath, let url = URL(string: imagePath) else { return }
        imageBanner.setImage(with: url)
    }
    
    override func prepareForReuse() {
        self.imageBanner.image = nil
        self.titleLabel.text = nil
    }
}
