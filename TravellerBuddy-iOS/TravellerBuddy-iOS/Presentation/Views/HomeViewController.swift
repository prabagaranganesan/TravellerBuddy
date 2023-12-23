//
//  HomeViewController.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation
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
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var placeItemViewModel: PlacesListViewModel = PlacesListViewModel()
    
    private lazy var placesListView: PlacesListView = {
        let view: PlacesListView = PlacesListView(viewModel: placeItemViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var categoryListView: CategoryListView = {
        let view: CategoryListView = CategoryListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sectionHeaderView: PlacesSectionHeaderView = {
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
        viewModel.fetchInitialVacationPlaces()
    }
    
    override func loadView() {
        view = UIView()
        setupView()
    }
    
    private func setupView() {
        [categoryListView, sectionHeaderView, placesListView].forEach({ stackView.addArrangedSubview($0) })
        contentView.addSubview(stackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        applyConstrainst()
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
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }
    
    private func bindViewModel() {
        viewModel.refreshPlaces = { [weak self] viewModel in
            DispatchQueue.main.async { //TODO: move to repository or viewmodel
                guard let self = self else { return }
                self.placesListView.refreshView(with: viewModel.items)
                self.sectionHeaderView.display(viewModel: self.viewModel.sectionHeaderViewModel)
                self.categoryListView.refreshView(with: self.viewModel.categories)
            }
        }
    }
}
