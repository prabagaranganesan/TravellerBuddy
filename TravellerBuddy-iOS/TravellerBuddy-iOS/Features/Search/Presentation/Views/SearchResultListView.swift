//
//  SearchResultListView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 29/12/23.
//

import Foundation
import MapKit
import UIKit

final class SearchResultListView: UIView {
    
    private lazy var tableView: UITableView = {
        let view: UITableView = UITableView.construct()
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var emptySearchResultView: SearchEmptyResultView = {
        let resultView: SearchEmptyResultView = SearchEmptyResultView(frame: .zero)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultView.isHidden = true
        return resultView
    }()
    
    private let completer = MKLocalSearchCompleter()
    private var searchText = ""
    private var viewModel: ISearchResultViewModel
    
    init(viewModel: ISearchResultViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubviews(tableView, emptySearchResultView)
        applyConstraints()
        configTableView()
        setupSearchCompleter()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            
            emptySearchResultView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            emptySearchResultView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            emptySearchResultView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
        ])
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(SearchResultItemCell.self, forCellReuseIdentifier: SearchResultItemCell.defaultReuseIdentifier)
        applyCornerRadius()
    }
    
    private func applyCornerRadius() {
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 12
    }
    
    private func bindViewModel() {
        viewModel.refreshItems = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        viewModel.showEmptyResultView = { [weak self] in
            guard let self = self else { return }
            self.emptySearchResultView.isHidden = false
        }
        
        viewModel.hideEmptyResultView = { [weak self] in
            self?.emptySearchResultView.isHidden = true
        }
    }
    
    func searchPlaces(searchText: String) {
        guard searchText.count > 2 else { return }
        self.searchText = searchText
        completer.queryFragment = searchText
    }
    
    func reset() {
        viewModel.reset()
        emptySearchResultView.isHidden = true
    }
    
    private func setupSearchCompleter() {
        completer.delegate = self
        completer.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [.aquarium, .marina, .beach, .museum, .zoo, .aquarium, .nationalPark, .park]))
        emptySearchResultView.displayData(viewModel: viewModel.getEmptyResultData())
    }
}

extension SearchResultListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultItemCell.defaultReuseIdentifier, for: indexPath) as? SearchResultItemCell else {
            return UITableViewCell()
        }
        let cellViewModel = viewModel.getItem(for: indexPath.row)
        cell.display(viewModel: cellViewModel)
        return cell
    }
}

extension SearchResultListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: handle tap action
    }
}

extension SearchResultListView: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        viewModel.searchResultsDidUpdate(results: completer.results, searchText: searchText)
    }
}
