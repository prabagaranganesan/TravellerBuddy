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

enum PlacesListLoadingType {
    case hideLoader
    case nextPage
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
    
    private var viewModel: IPlacesFeedViewModel
    private var nextPageLoadingSpinner: UICollectionReusableView?
    
    init(viewModel: IPlacesFeedViewModel, delegate: PlacesListNotificationDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(frame: .zero)
        setupView()
        setupCollectionView()
        bindViewModel()
        loadPlacess(queryText: "Beaches")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        self.addSubview(collectionView)
        applyConstraints()
        self.collectionView.reloadData()
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
        collectionView.register(PlacesListCell.self, forCellWithReuseIdentifier: PlacesListCell.defaultReuseIdentifier)
    }
    
    func refreshView(with data: [PlacesListItemUIModel]) {
        viewModel.updateData(viewModel: data)
        reloadItems()
    }
    
    func insertItems(sections: [Int], indexPaths: [IndexPath], newItems: [PlacesListItemUIModel]) {
        viewModel.addData(items: newItems)
        collectionView.performBatchUpdates { [weak self] in
            self?.collectionView.insertItems(at: indexPaths)
        }
    }
    
    private func reloadItems() {
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
    
    func loadPlacess(queryText: String) {
        viewModel.fetchInitialVacationPlaces(queryText: queryText)
    }
    
    func bindViewModel() {
        viewModel.refreshPlaces = { [weak self] response in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
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

