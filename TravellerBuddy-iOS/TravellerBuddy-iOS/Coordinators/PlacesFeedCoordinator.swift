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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = PlacessFeedViewModel()
        let placesFeedVC = PlacesFeedViewController(viewModel: viewModel)
        navigationController.pushViewController(placesFeedVC, animated: true)
    }
}
