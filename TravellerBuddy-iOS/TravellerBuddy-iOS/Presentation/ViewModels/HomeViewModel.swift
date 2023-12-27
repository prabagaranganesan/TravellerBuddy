//
//  HomeViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 22/12/23.
//

import Foundation

protocol IHomeViewModel {
    var refreshPlaces: (TouristListViewModel) -> Void { get set }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void { get set }
    var categories: [CategoryItemViewModel] { get }
    var sectionHeaderViewModel: SectionHeaderViewModel { get }
    var mapHeaderViewModel: SectionHeaderViewModel { get }
    var queryText: String { get }
    func updateQuery(text: String)
    func fetchInitialVacationPlaces(queryText: String)
    func fetchNextPage(queryText: String, indexPaths: [IndexPath])
}

final class HomeViewModel: IHomeViewModel {
    
    private let repository: TouristsRepository
    private var initialPageCount = 0
    private let paginationHelper: PaginationHelper
    private (set) var queryText: String = "Beaches"
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void = { (_, _) in }
    
    init(repository: TouristsRepository, paginationHelper: PaginationHelper = PaginationHelper()) {
        self.repository = repository
        self.paginationHelper = paginationHelper
    }
    
    func fetchInitialVacationPlaces(queryText: String) {
        let query = TouristQuery(query: queryText)
        repository.fetchTouristsList(query: query, page: initialPageCount) { cacheViewModel in
            //TODO: Handle cache data
            print(cacheViewModel)
        } completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let viewModel):
                paginationHelper.updatePageCount(by: 1)
                paginationHelper.addItems(newItems: viewModel.items)
                paginationHelper.updateTotalPage(count: viewModel.totalPageCount)
                self.refreshPlaces(viewModel)
            case .failure(let error):
                print(error)
                //TOOD: show error
            }
        }
    }
    
    func fetchNextPage(queryText: String, indexPaths: [IndexPath]) {
        guard paginationHelper.shouldFetchNextPage(indexPaths: indexPaths) else { return }
        paginationHelper.updatePageInProgress(status: true)
        let query = TouristQuery(query: queryText)
        repository.fetchTouristsList(query: query, page: paginationHelper.pageCount) { cacheViewModel in
            //TODO: Handle cache data
            print(cacheViewModel)
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.paginationHelper.updatePageInProgress(status: false)
            switch result {
            case .success(let viewModel):
                paginationHelper.addItems(newItems: viewModel.items)
                self.paginationHelper.updatePageCount(by: 1) //TODO: move to constant
                self.refreshNextPage(paginationHelper.nextIndexPaths, viewModel.items)
            case .failure(let error):
                print(error)
                //TOOD: show error
            }
        }
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
    
    func updateQuery(text: String) {
        queryText = text
    }
}

class PaginationHelper {
    var pageCount: Int = 0
    var nextIndexPaths: [IndexPath] = []
    private var totalAvailablePage = 3
    private var isNextPageInProgress = false
    private var totalItems: [PlacesListItemUIModel] = []
    
    func updatePageCount(by number: Int) {
        pageCount += number //TODO: handle concurrency
    }
    
    func shouldFetchNextPage(indexPaths: [IndexPath]) -> Bool {
        nextIndexPaths = indexPaths
        guard let firstIndexPath = indexPaths.first else { return false }
        return !isNextPageInProgress  && pageCount <= totalAvailablePage && totalItems.count <= firstIndexPath.row + 3
    }
    
    func updatePageInProgress(status: Bool) {
        isNextPageInProgress = status //TODO: handle concurrency
    }
    
    func addItems(newItems: [PlacesListItemUIModel]) {
        totalItems += newItems
    }
    
    func updateTotalPage(count: Int) {
        totalAvailablePage = count
    }
}
