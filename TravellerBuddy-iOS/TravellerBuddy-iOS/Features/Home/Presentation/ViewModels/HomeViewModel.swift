//
//  HomeViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation

protocol IHomeViewModel {
    var categories: [CategoryItemViewModel] { get }
    var sectionHeaderViewModel: SectionHeaderViewModel { get }
    var mapHeaderViewModel: SectionHeaderViewModel { get }
    func update(queryText: String)
    func exploreCTATapped()
    func showDetails(for id: String)
}

final class HomeViewModel: IHomeViewModel {
    
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    
    weak var homeCoordinator: HomeCoordinator?
    
    private let repository: TouristsRepository
    private var initialPageCount = 1
    private var queryText: String
    
    init(repository: TouristsRepository, queryText: String) {
        self.repository = repository
        self.queryText = queryText
    }
    
    var sectionHeaderViewModel: SectionHeaderViewModel {
        return SectionHeaderViewModel(title: "Recommended", ctaName: "Explore")
    }
    
    var mapHeaderViewModel: SectionHeaderViewModel {
        return SectionHeaderViewModel(title: "Based on your location", ctaName: "See map")
    }
    
    var categories: [CategoryItemViewModel] {
        let beachCategory = CategoryItemViewModel(title: "Beach", imageName: "beach_cat")
        let mountaintCategory = CategoryItemViewModel(title: "Mountain", imageName: "falls_cat")
        let waterFallsCategory = CategoryItemViewModel(title: "Water Falls", imageName: "mountain_cat")
        let forestCategory = CategoryItemViewModel(title: "Forests", imageName: "Forest")
        return [beachCategory, mountaintCategory, waterFallsCategory, forestCategory]
    }
    
    func update(queryText: String) {
        self.queryText = queryText
    }

    func exploreCTATapped() {
        homeCoordinator?.showPlacesFeedScreen(with: queryText)
    }
    
    func showDetails(for id: String) {
        homeCoordinator?.showDetails(for: id)
    }
}
