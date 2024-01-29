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
    func exploreCTATapped()
}

final class HomeViewModel: IHomeViewModel {
    
    var refreshPlaces: (TouristListViewModel) -> Void = { _ in }
    var refreshNextPage: ([IndexPath], [PlacesListItemUIModel]) -> Void = { (_, _) in }
    var showNextPageLoader: () -> Void = { }
    var hideNextPageLoader: () -> Void = { }
    
    weak var homeCoordinator: HomeCoordinator?
    
    private let repository: TouristsRepository
    private var initialPageCount = 1
    
    
    init(repository: TouristsRepository) {
        self.repository = repository
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

    func exploreCTATapped() {
        homeCoordinator?.showPlacesFeedScreen()
    }
}

class PaginationHelper {
    var pageCount: Int = 1
    var nextIndexPaths: [IndexPath] = []
    private var totalAvailablePage = 0
    private var isNextPageInProgress = false
    private var totalItems: [PlacesListItemUIModel] = []
    private let currentlyVisibleItemsCount = 3
    private var currentItems: [PlacesListItemUIModel] = []
    private let queue: DispatchQueue = DispatchQueue.main
    
    func updatePageCount(by number: Int) {
        pageCount += number //TODO: handle concurrency
    }
    
    func shouldFetchNextPage(indexPaths: [IndexPath], completion: @escaping (Bool) -> Void) {
        self.nextIndexPaths = indexPaths
        guard indexPaths.first != nil else {
            completion(false)
            return
        }
        guard !isNextPageInProgress else {
            completion(false)
            return
        }
        
        guard pageCount <= totalAvailablePage else {
            completion(false)
            return
        }
        
        guard isLastItem(indexPaths: indexPaths) else {
            completion(false)
            return
        }
        
        completion(pageCount <= totalAvailablePage)
    }

    func calculateIndexPathsToReload(from newItems:  [PlacesListItemUIModel]) -> [IndexPath] {
        let startIndex = totalItems.count - newItems.count
        let endIndex = startIndex + newItems.count
        return (startIndex..<endIndex).map{ IndexPath(row: $0, section: 0) }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= totalItems.count
    }
    
    private func isLastItem(indexPaths: [IndexPath]) -> Bool {
        for indexPath in indexPaths {
            if indexPath.row >= totalItems.count-1 {
                return true
            }
        }
        return false
    }
    
    func updatePageInProgress(status: Bool) {
        self.isNextPageInProgress = status //TODO: handle concurrency
    }
    
    func addItems(newItems: [PlacesListItemUIModel]) {
        self.currentItems = newItems
        self.totalItems += newItems
    }
    
    func updateTotalPage(count: Int) {
        self.totalAvailablePage = count
    }
    
    func reset() {
        self.totalItems = []
        self.nextIndexPaths = []
        self.pageCount = 1
        self.isNextPageInProgress = false
    }
    
    func updateCurrentItems(items: [PlacesListItemUIModel]) {
        self.currentItems = items
    }
}
