//
//  PlacesFeedViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 07/01/24.
//

import Foundation

protocol IPlacesFeedViewModel {
    var refreshPlaces: (TouristListViewModel) -> Void { get set }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void { get set }
    var showNextPageLoader: () -> Void { get set }
    var hideNextPageLoader: () -> Void { get set }
    var queryText: String { get }
    func fetchInitialVacationPlaces(queryText: String)
    func fetchNextPage(queryText: String, indexPaths: [IndexPath])
    func updateQuery(text: String)
    
    var numberOfItems: Int { get }
    func getItem(for index: Int) -> PlacesListItemUIModel?
    func updateData(viewModel: [PlacesListItemUIModel])
    func addData(items: [PlacesListItemUIModel])
}

final class PlacesFeedViewModel: IPlacesFeedViewModel {
    
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void = { (_, _) in }
    var showNextPageLoader: () -> Void = { }
    var hideNextPageLoader: () -> Void = { }
    
    private let repository: TouristsRepository
    private let paginationHelper: PaginationHelper
    private var initialPageCount = 1
    private (set) var queryText: String = "Beaches"
    private var items: [PlacesListItemUIModel] = []
    private var totalItemsCount: Int = 0
    
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
                self.handleSuccess(viewModel: viewModel)
            case .failure(let error):
                print(error)
                //TOOD: show error
            }
        }
    }
    
    func fetchNextPage(queryText: String, indexPaths: [IndexPath]) {
        
        paginationHelper.shouldFetchNextPage(indexPaths: indexPaths) { [weak self] shouldFetch in
            guard let self = self, shouldFetch else {
                self?.hideNextPageLoader()
                return
            }
            self.showNextPageLoader()
            self.paginationHelper.updatePageInProgress(status: true)
            let query = TouristQuery(query: queryText)
            print("fetching next data")
            self.repository.fetchTouristsList(query: query, page: self.paginationHelper.pageCount) { cacheViewModel in
                //TODO: Handle cache data
                print(cacheViewModel)
            } completion: { [weak self] result in
                guard let self = self else { return }
                self.paginationHelper.updatePageInProgress(status: false)
                switch result {
                case .success(let viewModel):
                    self.handleNextPageSuccess(viewModel: viewModel)
                case .failure(let error):
                    print(error)
                    //TOOD: show error
                }
            }
        }
    }
    
    private func handleSuccess(viewModel: TouristListViewModel) {
        paginationHelper.updatePageCount(by: 1)
        paginationHelper.addItems(newItems: viewModel.items)
        paginationHelper.updatePageInProgress(status: false)
        items = viewModel.items
        paginationHelper.updateCurrentItems(items: viewModel.items)
        totalItemsCount = viewModel.totalItemCount
        paginationHelper.updateTotalPage(count: viewModel.totalPageCount)
        refreshPlaces(viewModel)
    }
    
    private func handleNextPageSuccess(viewModel: TouristListViewModel) {
        paginationHelper.addItems(newItems: viewModel.items)
        items.append(contentsOf: viewModel.items)
        paginationHelper.updatePageCount(by: 1) //TODO: move to constant
        let indexPathsToReload = paginationHelper.calculateIndexPathsToReload(from: viewModel.items)
        refreshNextPage(indexPathsToReload, viewModel.items)
    }
    
    func updateQuery(text: String) {
        queryText = text
        paginationHelper.reset()
    }
}

extension PlacesFeedViewModel {
    
    var numberOfItems: Int {
        return totalItemsCount
    }
    
    func getItem(for index: Int) -> PlacesListItemUIModel? {
        guard !(index >= items.count) else {
            return nil
        }
        return items[index]
    }
    
    func updateData(viewModel: [PlacesListItemUIModel]) { //TODO: combine this logic to below method
        self.items = viewModel
    }
    
    func addData(items: [PlacesListItemUIModel]) {
        self.items.append(contentsOf: items)
    }
}
