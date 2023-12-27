//
//  TouristListViewModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

struct TouristListViewModel: Equatable {
    
    let items: [PlacesListItemUIModel]
    let totalPageCount: Int
}

struct PlacesListItemUIModel: Equatable {
    let title: String?
    let imagePath: String?
}
