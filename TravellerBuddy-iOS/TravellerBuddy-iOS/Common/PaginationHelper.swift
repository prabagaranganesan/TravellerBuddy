//
//  PaginationHelper.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 17/02/24.
//

import Foundation

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
