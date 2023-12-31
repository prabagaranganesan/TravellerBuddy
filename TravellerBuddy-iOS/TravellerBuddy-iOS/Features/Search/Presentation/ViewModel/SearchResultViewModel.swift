//
//  SearchResultViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 31/12/23.
//

import Foundation
import MapKit

protocol ISearchResultViewModel {
    var numberOfRows: Int { get }
    var refreshItems: () -> Void { get set }
    var showEmptyResultView: () -> Void { get set }
    var hideEmptyResultView: () -> Void { get set }
    func getItem(for index: Int) -> SearchResultCellViewModel
    func searchResultsDidUpdate(results: [MKLocalSearchCompletion], searchText: String)
    func reset()
    func getEmptyResultData() -> EmptySearchViewModel
}

final class SearchResultViewModel: ISearchResultViewModel {
    
    var refreshItems: () -> Void = { }
    var showEmptyResultView: () -> Void = { }
    var hideEmptyResultView: () -> Void = { }
    private var items: [SearchResultCellViewModel] = []
    
    var numberOfRows: Int {
        return items.count
    }

    func getItem(for index: Int) -> SearchResultCellViewModel {
        return items[index]
    }
    
    func searchResultsDidUpdate(results: [MKLocalSearchCompletion], searchText: String) {
        items = results.map { $0.toDomain() }
        guard !items.isEmpty else {
            showEmptyResultView()
            refreshItems()
            return
        }
        hideEmptyResultView()
        refreshItems()
    }
    
    func reset() {
        items = []
        self.refreshItems()
    }
    
    func getEmptyResultData() -> EmptySearchViewModel {
        return EmptySearchViewModel(title: "No places found for your searches", message: "Please try to change your search name")//TODO: localise
    }
}
