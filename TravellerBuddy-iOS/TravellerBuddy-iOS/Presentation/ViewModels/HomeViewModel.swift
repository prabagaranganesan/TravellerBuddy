//
//  HomeViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation

protocol IHomeViewModel {
    var refreshPlaces: (TouristListViewModel) -> Void { get set }
    func fetchInitialVacationPlaces()
}


final class HomeViewModel: IHomeViewModel {
    
    private let repository: TouristsRepository
    private var pageCount = 1
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    
    init(repository: TouristsRepository) {
        self.repository = repository
    }
    
    func fetchInitialVacationPlaces() {
        let query = TouristQuery(query: "Beaches")
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
}
