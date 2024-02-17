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
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var searchBaseStackView: UIStackView = {
        let stackView: UIStackView = UIStackView.construct()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.backgroundColor = .clear
        return stackView
    }()
        
    private lazy var placesListView: PlacesListView = {
        let view: PlacesListView = PlacesListView(viewModel: placesFeedViewModel, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryListView: CategoryListView = {
        let view: CategoryListView = CategoryListView(delegate: self)
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
        searchBar.placeholder = "Search destination..." //TODO: update copies
        return searchBar
    }()
    
    private lazy var searchbarContainer: UIStackView = {
        let view: UIStackView = UIStackView.construct()
        view.backgroundColor = .clear
        view.distribution = .fill
        view.axis = .horizontal
        return view
    }()
    
    private var searchViewModel: ISearchResultViewModel
    private var placesFeedViewModel: IPlacesFeedViewModel
    
    private lazy var searchResultView: SearchResultListView = {
        let view: SearchResultListView = SearchResultListView(viewModel: searchViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        button.isHidden = true
        button.imageView?.tintColor = .gray
        button.imageView?.contentMode = .scaleToFill
        button.addTarget(self, action: #selector(searchBackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //TODO: Move this map related view to different component and bleow secion
    lazy var mapView: MKMapView = {
        let view: MKMapView = MKMapView()
        let noLocation = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
        let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        view.setRegion(viewRegion, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placesListHeaderView: PlacesSectionHeaderView = {
        let view: PlacesSectionHeaderView = PlacesSectionHeaderView(tapDelegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mapHeaderView: PlacesSectionHeaderView = {
        let view: PlacesSectionHeaderView = PlacesSectionHeaderView(tapDelegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var scrollViewTopConstraint: NSLayoutConstraint?
    private var viewModel: IHomeViewModel

    
    init(viewModel: IHomeViewModel, searchViewModel: ISearchResultViewModel, placesFeedViewModel: IPlacesFeedViewModel) {
        self.viewModel = viewModel
        self.searchViewModel = searchViewModel
        self.placesFeedViewModel = placesFeedViewModel
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
        [backButton, searchBar].forEach { searchbarContainer.addArrangedSubview($0) }
        [searchbarContainer, searchResultView].forEach { searchBaseStackView.addArrangedSubview($0) }
        [categoryListView, placesListHeaderView, placesListView, mapHeaderView, mapView].forEach({ stackView.addArrangedSubview($0) })
        contentView.addSubviews(searchBaseStackView, stackView) /// Taken decision to have search result view in same screen instead of going to another new screen, so that user won't feel that too much action going on and he will stay on the same screen it will be much smoother
        scrollView.addSubview(contentView)
        view.addSubviews(scrollView)
        applyConstrainst()
        addSearchBarCornerRadius()
        stackView.setCustomSpacing(0, after: searchbarContainer)
        stackView.setCustomSpacing(24, after: categoryListView)
        stackView.setCustomSpacing(30, after: placesListView)
        stackView.setCustomSpacing(24, after: mapHeaderView)
        searchbarContainer.setCustomSpacing(16, after: searchBar)
        searchbarContainer.isLayoutMarginsRelativeArrangement = true
        searchbarContainer.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func applyConstrainst() {
        let scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollViewTopConstraint,
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            searchBaseStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchBaseStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            searchBaseStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: searchBaseStackView.topAnchor, constant: 40),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            mapView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2.4),
            
            searchResultView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height-130)
        ])
        self.scrollViewTopConstraint = scrollViewTopConstraint
    }
    
    private func addSearchBarCornerRadius() {
        searchBar.layer.cornerRadius = 24
        searchBar.layer.masksToBounds = true
    }
    
    private func loadInitialData() {
        placesListHeaderView.display(viewModel: self.viewModel.sectionHeaderViewModel)
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
    
    @objc
    private func searchBackButtonTapped() {
        resetSearchBar()
    }
    
    private func bindViewModel() {
        placesFeedViewModel.refreshPlaces = { [weak self] viewModel in
            DispatchQueue.main.async { //TODO: move to repository or viewmodel
                guard let self = self else { return }
                self.placesListView.refreshView(with: viewModel.items)
            }
        }
    }
}

extension HomeViewController: CategoryItemTapDelegate {
    
    func categoryItemTapped(category: String) {
        placesFeedViewModel.updateQuery(text: category)
        placesFeedViewModel.fetchInitialVacationPlaces(queryText: category)
        viewModel.update(queryText: category)
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResultView.reset()
            return
            
        }
        searchResultView.searchPlaces(searchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        playSearchAnimation()
    }
    
    private func resetSearchBar() {
        searchBar.endEditing(true)
        backButton.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        stackView.isHidden = false
        searchResultView.isHidden = true
        searchBar.text = ""
        searchbarContainer.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        searchResultView.reset()

        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { [weak self] in
            self?.scrollView.layoutIfNeeded()
        })
    }
    
    private func playSearchAnimation() {
        backButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        searchbarContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        stackView.isHidden = true
        searchResultView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.scrollView.layoutIfNeeded()
        })
    }
}

extension HomeViewController: PlacesListNotificationDelegate, MKLocalSearchCompleterDelegate {
    func getNextPage(indexPaths: [IndexPath]) {
        placesFeedViewModel.fetchNextPage(queryText: placesFeedViewModel.queryText, indexPaths: indexPaths)
    }
    
    func showError(error: Error) {
        let alertCard = AlertCard.card(for: .noInternetRetry)
        alertCard?.showFromVC(self.navigationController, animated: true, completion: nil)
    }
}

extension HomeViewController: PlacesListHeaderTapDelegate {
    func rightCTATapped() {
        viewModel.exploreCTATapped()
    }
}
