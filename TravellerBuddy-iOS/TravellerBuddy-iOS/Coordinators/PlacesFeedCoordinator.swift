//
//  PlacesFeedCoordinator.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 04/01/24.
//

import Foundation
import UIKit

final class PlacesFeedCoordinator {
    
    private let navigationController: UINavigationController
    private let appDIController: AppDIContainer

    init(navigationController: UINavigationController, appDIController: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIController = appDIController
    }
    
    func start(with queryText: String) {
        let touristReposiotry = DefaultTouristsRepository(dataTransferService: appDIController.apiDataTransferService)
        let viewModel = PlacesFeedViewModel(repository: touristReposiotry, queryText: queryText)
        let placesFeedVC = PlacesFeedViewController(viewModel: viewModel)
        navigationController.pushViewController(placesFeedVC, animated: true)
    }
}
