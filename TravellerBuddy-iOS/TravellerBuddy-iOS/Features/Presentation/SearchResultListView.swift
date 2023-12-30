//
//  SearchResultListView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 29/12/23.
//

import Foundation
import UIKit

final class SearchResultListView: UIView {
    
    private lazy var tableView: UITableView = {
        let view: UITableView = UITableView.construct()
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()
    
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
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
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
    }
    
    private func bindViewModel() {
        viewModel.refreshItems = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func searchPlaces(searchText: String) {
        viewModel.searchPlaces(searchText: searchText)
    }
    
    func reset() {
        viewModel.reset()
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

struct SearchResultItemViewModel {
    let title: String
}

final class SearchResultItemCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var chevronIcon: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        view.image = UIImage(systemName: "chevron.right")
        view.contentMode = .scaleAspectFit
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
        self.contentView.addSubviews(titleLabel, chevronIcon)
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            
            chevronIcon.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            chevronIcon.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            chevronIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronIcon.heightAnchor.constraint(equalToConstant: 20),
            chevronIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func display(viewModel: SearchResultItemViewModel) {
        titleLabel.text = viewModel.title
    }
}

protocol ISearchResultViewModel {
    var numberOfRows: Int { get }
    var refreshItems: () -> Void { get set }
    func getItem(for index: Int) -> SearchResultItemViewModel
    func searchPlaces(searchText: String)
    func reset()
}

final class SearchResultViewModel: ISearchResultViewModel {
    
    var refreshItems: () -> Void = { }
    
    private let repository: MapSearchRepositoy
    private var items: [SearchResultItemViewModel] = []
    
    init(repository: MapSearchRepositoy) {
        self.repository = repository
    }
    
    var numberOfRows: Int {
        return items.count
    }

    func getItem(for index: Int) -> SearchResultItemViewModel {
        return items[index]
    }
    
    func searchPlaces(searchText: String) {
        repository.searchPlaces(using: searchText + "Vacation") { [weak self] results in
            guard let self = self else { return }
            self.items = results
            self.refreshItems()
        }
    }
    
    func reset() {
        items = []
        self.refreshItems()
    }
}

import MapKit

protocol MapSearchRepositoy {
    func searchPlaces(using searchText: String, completion: @escaping ([SearchResultItemViewModel]) -> Void)
}

final class MapKitMapSearchRepository: MapSearchRepositoy {
    
    func searchPlaces(using searchText: String, completion: @escaping ([SearchResultItemViewModel]) -> Void) {
        let request = getTourPlacesSearchRequest(searchText: searchText)
        let search = MKLocalSearch(request: request)

        search.start { response, _ in
            guard let response = response else {
                return
            }
            completion(response.mapItems.map { $0.toDomain() })
        }
    }
    
    private func getTourPlacesSearchRequest(searchText: String) -> MKLocalSearch.Request {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKMapView().region //TODO: pass current region
        request.resultTypes = .pointOfInterest
        return request
    }
}

extension MKMapItem {
    
    func toDomain() -> SearchResultItemViewModel {
        return SearchResultItemViewModel(title: self.name ?? "")
    }
}
