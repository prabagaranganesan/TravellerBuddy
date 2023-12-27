//
//  PlacesListView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation
import UIKit

protocol PlacesListNotificationDelegate: AnyObject {
    func getNextPage(indexPaths: [IndexPath])
}

final class PlacesListView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isScrollEnabled = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    weak var delegate: PlacesListNotificationDelegate?
    
    private let viewModel: IPlacesListViewModel
    
    init(viewModel: IPlacesListViewModel, delegate: PlacesListNotificationDelegate?) {
        self.viewModel = viewModel
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
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.5 - 8)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(PlacesListCell.self, forCellWithReuseIdentifier: PlacesListCell.defaultReuseIdentifier)
    }
    
    func refreshView(with data: [PlacesListItemUIModel]) {
        viewModel.updateData(viewModel: data)
        collectionView.reloadData()
    }
    
    func insertItems(sections: [Int], indexPaths: [IndexPath], newItems: [PlacesListItemUIModel]) {
        viewModel.addData(items: newItems)
        collectionView.reloadData()
    }
    
    private func getIndexPaths(start: Int, end: Int) -> IndexPath {
        return IndexPath(row: start + end, section: 0)
    }
}

extension PlacesListView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlacesListCell.defaultReuseIdentifier, for: indexPath) as? PlacesListCell else { return UICollectionViewCell()
        }
        let item = viewModel.getItem(for: indexPath.row)
        cell.display(viewModel: item)
        return cell
    }
}

extension PlacesListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 1.7
        return CGSize(width: width - 32, height: UIScreen.main.bounds.width / 1.5 - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
    }
}

extension PlacesListView: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        delegate?.getNextPage(indexPaths: indexPaths)
    }
}

protocol IPlacesListViewModel {
    var numberOfItems: Int { get }
    func getItem(for index: Int) -> PlacesListItemUIModel?
    func updateData(viewModel: [PlacesListItemUIModel])
    func addData(items: [PlacesListItemUIModel])
}

final class PlacesListViewModel: IPlacesListViewModel {
    
    private var items: [PlacesListItemUIModel] = []
    
    var numberOfItems: Int {
        return items.count
    }
    
    func getItem(for index: Int) -> PlacesListItemUIModel? {
        guard !(index >= items.count) else {
            return nil
        }
        return items[index]
    }
    
    func updateData(viewModel: [PlacesListItemUIModel]) { //TODO: combine this logic to below method
        self.items = viewModel
    }
    
    func addData(items: [PlacesListItemUIModel]) {
        self.items.append(contentsOf: items)
    }
}
