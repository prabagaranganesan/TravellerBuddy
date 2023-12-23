//
//  HomeViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation

protocol IHomeViewModel {
    var refreshPlaces: (TouristListViewModel) -> Void { get set }
    var categories: [CategoryItemViewModel] { get }
    var sectionHeaderViewModel: SectionHeaderViewModel { get }
    func fetchInitialVacationPlaces(queryText: String)
}

final class HomeViewModel: IHomeViewModel {
    
    private let repository: TouristsRepository
    private var pageCount = 1
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    
    init(repository: TouristsRepository) {
        self.repository = repository
    }
    
    func fetchInitialVacationPlaces(queryText: String) {
        let query = TouristQuery(query: queryText)
        repository.fetchTouristsList(query: query, page: pageCount) { cacheViewModel in
            //TODO: Handle cache data
            print(cacheViewModel)
        } completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let viewModel):
                self.refreshPlaces(viewModel)
                print(viewModel)
            case .failure(let error):
                print(error)
                //TOOD: show error
            }
        }

    }
    
    var sectionHeaderViewModel: SectionHeaderViewModel {
        return SectionHeaderViewModel(title: "Recommended", ctaName: "Explore")
    }
    
    var categories: [CategoryItemViewModel] {
        let beachCategory = CategoryItemViewModel(title: "Beach", imageName: "beach_cat")
        let mountaintCategory = CategoryItemViewModel(title: "Mountain", imageName: "falls_cat")
        let waterFallsCategory = CategoryItemViewModel(title: "Water Falls", imageName: "mountain_cat")
        let forestCategory = CategoryItemViewModel(title: "Forests", imageName: "Forest")
        return [beachCategory, mountaintCategory, waterFallsCategory, forestCategory]
    }
}
