//
//  HomeCoordinator.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation
import UIKit

final class HomeCoordinator {
    private let navigationController: UINavigationController
    private let appDIController: AppDIContainer
    private var placesFeedCoordinator: PlacesFeedCoordinator?
    
    init(navigationController: UINavigationController, appDIController: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIController = appDIController
    }
    
    func start() {
        //TODO: move to factory class
        let touristReposiotry = DefaultTouristsRepository(dataTransferService: appDIController.apiDataTransferService)
        let viewModel = HomeViewModel(repository: touristReposiotry, queryText: "Beaches")
        viewModel.homeCoordinator = self
        let searchViewModel = SearchResultViewModel()
        let placesFeedViewModel = PlacesFeedViewModel(repository: touristReposiotry, queryText: "Beaches")
        let homeViewController = HomeViewController(viewModel: viewModel, searchViewModel: searchViewModel, placesFeedViewModel: placesFeedViewModel)
        navigationController.pushViewController(homeViewController, animated: true)
    }
    
    func showPlacesFeedScreen(with queryText: String) {
        placesFeedCoordinator = PlacesFeedCoordinator(navigationController: self.navigationController, appDIController: appDIController)
        placesFeedCoordinator?.start(with: queryText)
    }
}
