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
    
    init(navigationController: UINavigationController, appDIController: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIController = appDIController
    }
    
    func start() {
        //TODO: move to factory class
        let touristReposiotry = DefaultTouristsRepository(dataTransferService: appDIController.apiDataTransferService)
        let viewModel = HomeViewModel(repository: touristReposiotry)
        let searchViewModel = SearchResultViewModel()
        let homeViewController = HomeViewController(viewModel: viewModel, searchViewModel: searchViewModel)
        navigationController.pushViewController(homeViewController, animated: true)
    }
}
