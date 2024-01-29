//
//  RootCoordinator.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation
import UIKit

final class RootCoordinator {
    private let navigationController: UINavigationController
    private let appDIController: AppDIContainer
    private var homeCoordinator: HomeCoordinator?
    
    init(navigationController: UINavigationController, appDIController: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIController = appDIController
    }
    
    func start() {
       ///Start Login coordinator if user is not login once login flow available
       ///Since we don't have login screen yet,  we are directly showing home screen
        self.homeCoordinator = HomeCoordinator(navigationController: navigationController, appDIController: appDIController)
        self.homeCoordinator?.start()
    }
}


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
        let viewModel = HomeViewModel(repository: touristReposiotry)
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
