//
//  CategoryListView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 23/12/23.
//

import Foundation
import UIKit

struct CategoryItemViewModel {
    let title: String
    let imageName: String
}

protocol CategoryItemTapDelegate: AnyObject {
    func categoryItemTapped(category: String)
}

final class CategoryListView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 14
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
        
    private var items: [CategoryItemViewModel] = []
    var delegate: CategoryItemTapDelegate?
    
    init(delegate: CategoryItemTapDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(collectionView)
        applyConstraints()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16),
            collectionView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryItemCell.self, forCellWithReuseIdentifier: CategoryItemCell.defaultReuseIdentifier)
    }
    
    func refreshView(with data: [CategoryItemViewModel]) {
        items = data
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
    }
}

extension CategoryListView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCell.defaultReuseIdentifier, for: indexPath) as? CategoryItemCell else { return UICollectionViewCell()
        }
        let item = items[indexPath.row]
        cell.display(viewModel: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        delegate?.categoryItemTapped(category: selectedItem.title)
    }
}

extension CategoryListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 20)
    }
}


final class CategoryItemCell: UICollectionViewCell {
    
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
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.contentView.backgroundColor = UIColor(red: 64.00/255.00, green: 193.00/255.00, blue: 146.00/255.00, alpha: 1.00) //TODO: change to common color component
                self.titleLabel.textColor = .white
            } else {
                self.contentView.backgroundColor = .white
                self.titleLabel.textColor = .black
            }
        }
    }
    
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
            imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -8),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func applyCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 15
    }
    
    func display(viewModel: CategoryItemViewModel) {
        titleLabel.text = viewModel.title.localizedCapitalized
        imageView.image = UIImage(named: viewModel.imageName)
    }
}
