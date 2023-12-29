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
    var showNextPageLoader: () -> Void { get set }
    var hideNextPageLoader: () -> Void { get set }
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
    private var initialPageCount = 1
    private let paginationHelper: PaginationHelper
    private (set) var queryText: String = "Beaches"
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void = { (_, _) in }
    var showNextPageLoader: () -> Void = { }
    var hideNextPageLoader: () -> Void = { }
    
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
        paginationHelper.updateTotalPage(count: viewModel.totalPageCount)
        refreshPlaces(viewModel)
    }
    
    private func handleNextPageSuccess(viewModel: TouristListViewModel) {
        paginationHelper.addItems(newItems: viewModel.items)
        paginationHelper.updatePageCount(by: 1) //TODO: move to constant
        refreshNextPage(paginationHelper.nextIndexPaths, viewModel.items)
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
        paginationHelper.reset()
    }
}

class PaginationHelper {
    var pageCount: Int = 1
    var nextIndexPaths: [IndexPath] = []
    private var totalAvailablePage = 0
    private var isNextPageInProgress = false
    private var totalItems: [PlacesListItemUIModel] = []
    private let currentlyVisibleItemsCount = 3
    private let queue: DispatchQueue = DispatchQueue.main
    
    func updatePageCount(by number: Int) {
        pageCount += number //TODO: handle concurrency
    }
    
    func shouldFetchNextPage(indexPaths: [IndexPath], completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            self.nextIndexPaths = indexPaths
            guard let firstIndexPath = indexPaths.first else {
                completion(false)
                return
            }
            let status = !isNextPageInProgress && pageCount <= totalAvailablePage && totalItems.count <= firstIndexPath.row + currentlyVisibleItemsCount
            completion(status)
        }
    }
    
    func updatePageInProgress(status: Bool) {
        queue.async { [weak self] in
            self?.isNextPageInProgress = status //TODO: handle concurrency
        }
    }
    
    func addItems(newItems: [PlacesListItemUIModel]) {
        queue.async { [weak self] in
            self?.totalItems += newItems
        }
    }
    
    func updateTotalPage(count: Int) {
        queue.async { [weak self] in
            self?.totalAvailablePage = count
        }
    }
    
    func reset() {
        queue.async { [weak self] in
            self?.totalItems = []
            self?.nextIndexPaths = []
            self?.pageCount = 1
            self?.isNextPageInProgress = false
        }
    }
}
