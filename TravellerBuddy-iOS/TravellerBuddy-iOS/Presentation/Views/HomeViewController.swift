//
//  HomeViewController.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation
import MapKit
import UIKit

class HomeViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView.construct()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view: UIView = UIView.construct()
        return view
    }()
        
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView.construct()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var placeItemViewModel: PlacesListViewModel = PlacesListViewModel()
    
    private lazy var placesListView: PlacesListView = {
        let view: PlacesListView = PlacesListView(viewModel: placeItemViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryListView: CategoryListView = {
        let view: CategoryListView = CategoryListView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sectionHeaderView: PlacesSectionHeaderView = {
        let view: PlacesSectionHeaderView = PlacesSectionHeaderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .prominent
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.clipsToBounds = true
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.placeholder = "Search destination..."
        return searchBar
    }()
    
    private lazy var searchbarContainer: UIView = {
        let view: UIView = UIView.construct()
        view.backgroundColor = .clear
        return view
    }()
    
    //TODO: Move this map related view to different componen and bleow secion
    lazy var mapView = {
        let view: MKMapView = MKMapView()
        let noLocation = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
        let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        view.setRegion(viewRegion, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapHeaderView: PlacesSectionHeaderView = {
        let view: PlacesSectionHeaderView = PlacesSectionHeaderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var viewModel: IHomeViewModel
    
    init(viewModel: IHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemGray6
        bindViewModel()
        loadInitialData()
        viewModel.fetchInitialVacationPlaces(queryText: "Beaches")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBar()
    }
    
    override func loadView() {
        view = UIView()
        setupView()
    }
    
    private func setupView() {
        searchbarContainer.addSubview(searchBar)
        [searchbarContainer, categoryListView, sectionHeaderView, placesListView, mapHeaderView, mapView].forEach({ stackView.addArrangedSubview($0) })
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        applyConstrainst()
        addSearchBarCornerRadius()
        stackView.setCustomSpacing(0, after: searchbarContainer)
        stackView.setCustomSpacing(24, after: categoryListView)
        stackView.setCustomSpacing(30, after: placesListView)
        stackView.setCustomSpacing(24, after: mapHeaderView)
    }
    
    private func applyConstrainst() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            searchBar.leadingAnchor.constraint(equalTo: searchbarContainer.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: searchbarContainer.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: searchbarContainer.topAnchor, constant: 0),
            searchBar.bottomAnchor.constraint(equalTo: searchbarContainer.bottomAnchor, constant: 0),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            mapView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2.4)
        ])
    }
    
    private func addSearchBarCornerRadius() {
        searchBar.layer.cornerRadius = 24
        searchBar.layer.masksToBounds = true
    }
    
    private func loadInitialData() {
        sectionHeaderView.display(viewModel: self.viewModel.sectionHeaderViewModel)
        categoryListView.refreshView(with: self.viewModel.categories)
        mapHeaderView.display(viewModel: viewModel.mapHeaderViewModel)
    }
    
    private func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Explore Places"
        let bellButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(notificationTapped))
        bellButton.tintColor = .darkGray
        self.navigationItem.rightBarButtonItem  = bellButton
    }
    
    @objc
    private func notificationTapped() {
        //TODO: handle tap action
    }
    
    private func bindViewModel() {
        viewModel.refreshPlaces = { [weak self] viewModel in
            DispatchQueue.main.async { //TODO: move to repository or viewmodel
                guard let self = self else { return }
                self.placesListView.refreshView(with: viewModel.items)
            }
        }
        
        viewModel.refreshNextPage = { [weak self] (indexPath, items) in
            DispatchQueue.main.async { //TODO: move to repository or viewmodel
                guard let self = self else { return }
                self.placesListView.insertItems(sections: [], indexPaths: indexPath, newItems: items)
            }
        }
    }
}

extension HomeViewController: CategoryItemTapDelegate {
    
    func itemTapped(category: String) {
        viewModel.updateQuery(text: category)
        viewModel.fetchInitialVacationPlaces(queryText: category)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}

extension HomeViewController: PlacesListNotificationDelegate {
    func getNextPage(indexPaths: [IndexPath]) {
        viewModel.fetchNextPage(queryText: viewModel.queryText, indexPaths: indexPaths)
    }
}
