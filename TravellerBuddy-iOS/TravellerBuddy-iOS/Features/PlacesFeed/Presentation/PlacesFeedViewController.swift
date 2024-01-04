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
    
    private let viewModel: IPlacesFeedViewModel
    
    init(viewModel: IPlacesFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
       
        tableView.register(PlacesFeedCell.self, forCellReuseIdentifier: PlacesFeedCell.defaultReuseIdentifier)
    }
}

extension PlacesFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlacesFeedCell.defaultReuseIdentifier, for: indexPath) as? PlacesFeedCell else {
            return UITableViewCell()
        }
        
        cell.display(viewModel: nil) //TODO: pass viewModel here
        return cell
    }
}

extension PlacesFeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: handle tap action
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

final class PlacesFeedCell: UITableViewCell {
    private var titleLabel: UILabel = {
        let label: UILabel = UILabel.construct()
        label.font = .boldSystemFont(ofSize: 14) //TODO: import font from json so that it will be easy to switch to different font with less work
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var imageBanner: UIImageView = {
        let view: UIImageView = UIImageView.construct()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.backgroundColor = .white
        contentView.addSubviews(imageBanner, titleLabel)
        applyConstraints()
        applyCornerRadius()
    }
    
    private func applyConstraints() {
        
        NSLayoutConstraint.activate([
            imageBanner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageBanner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageBanner.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageBanner.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            imageBanner.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func applyCornerRadius() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        
        self.imageBanner.clipsToBounds = true
        self.imageBanner.layer.cornerRadius = 12
    }
    
    func display(viewModel: PlacesListItemUIModel?) {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.title?.localizedCapitalized
        guard let imagePath = viewModel.imagePath, let url = URL(string: imagePath) else { return }
        imageBanner.setImage(with: url)
    }
}

protocol IPlacesFeedViewModel {
    var numberOfRows: Int { get }
}

final class PlacessFeedViewModel: IPlacesFeedViewModel {
    
    var numberOfRows: Int {
        return 10
    }
}
