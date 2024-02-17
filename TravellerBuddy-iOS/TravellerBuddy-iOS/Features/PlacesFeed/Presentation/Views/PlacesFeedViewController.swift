//
//  PlacesFeedViewController.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 04/01/24.
//

import Foundation
import UIKit

final class PlacesFeedViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView.construct()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var viewModel: IPlacesFeedViewModel
    
    init(viewModel: IPlacesFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.fetchInitialVacationPlaces(queryText: viewModel.queryText)
    }
    
    override func loadView() {
        view = UIView()
        setupNavigationbar()
        setupView()
    }
    
    private func setupView() {
        self.view.addSubview(tableView)
        self.view.backgroundColor = .white
        applyConstraints()
        configTableView()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16)
        ])
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
       
        tableView.register(PlacesFeedCell.self, forCellReuseIdentifier: PlacesFeedCell.defaultReuseIdentifier)
    }
    
    private func bindViewModel() {
        viewModel.refreshPlaces = { [weak self] response in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        viewModel.refreshNextPage = { (indexPaths, items) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let indexPathToReload = self.visibleIndexPathsToReload(indexPaths: indexPaths, visibleIndexPaths: self.tableView.indexPathsForVisibleRows ?? [])
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
            }
        }
        
        viewModel.showNextPageLoader = {
            
        }
        
        viewModel.hideNextPageLoader = {
            
        }
    }
}

extension PlacesFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlacesFeedCell.defaultReuseIdentifier, for: indexPath) as? PlacesFeedCell else {
            return UITableViewCell()
        }
        let item = viewModel.getItem(for: indexPath.row)
        cell.display(viewModel: item) //TODO: pass viewModel here
        return cell
    }
}

extension PlacesFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: handle tap action
    }
}

extension PlacesFeedViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        viewModel.fetchNextPage(queryText: viewModel.queryText, indexPaths: indexPaths)
    }
    
    private func visibleIndexPathsToReload(indexPaths: [IndexPath], visibleIndexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathInterSection = Set(visibleIndexPaths).intersection(indexPaths)
        return Array(indexPathInterSection)
    }
}


//Navigation bar setup
extension PlacesFeedViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func setupNavigationbar() {
        self.title = "Beaches" //TODO: text should be passed from parent controller
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left", withConfiguration:  UIImage.SymbolConfiguration(weight: .bold)), style: .plain, target: self, action: #selector(backButtonClicked(_:)))
        backButton.tintColor = .darkGray
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonClicked(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
