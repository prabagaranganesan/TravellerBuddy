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
    
    private let completer = MKLocalSearchCompleter()
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
        self.addSubviews(tableView)
        applyConstraints()
        configTableView()
        setupSearchCompleter()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
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
    }
    
    func searchPlaces(searchText: String) {
        completer.queryFragment = searchText
    }
    
    func reset() {
        viewModel.reset()
    }
    
    private func setupSearchCompleter() {
        completer.delegate = self
        completer.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [.aquarium, .marina, .beach, .museum, .zoo, .aquarium, .nationalPark, .park]))
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
        viewModel.searchResultsDidUpdate(results: completer.results)
    }
}

struct SearchResultItemViewModel {
    let title: String
    let subTitle: String
}

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
    
    func display(viewModel: SearchResultItemViewModel) {
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
    }
}

protocol ISearchResultViewModel {
    var numberOfRows: Int { get }
    var refreshItems: () -> Void { get set }
    func getItem(for index: Int) -> SearchResultItemViewModel
    func searchResultsDidUpdate(results: [MKLocalSearchCompletion])
    func reset()
}

final class SearchResultViewModel: ISearchResultViewModel {
    
    var refreshItems: () -> Void = { }
    
    private var items: [SearchResultItemViewModel] = []
    
    var numberOfRows: Int {
        return items.count
    }

    func getItem(for index: Int) -> SearchResultItemViewModel {
        return items[index]
    }
    
    func searchResultsDidUpdate(results: [MKLocalSearchCompletion]) {
        items = results.map { $0.toDomain() }
        refreshItems()
    }
    
    func reset() {
        items = []
        self.refreshItems()
    }
}

extension MKLocalSearchCompletion {
    
    func toDomain() -> SearchResultItemViewModel {
        return SearchResultItemViewModel(title: self.title, subTitle: subtitle)
    }
}
