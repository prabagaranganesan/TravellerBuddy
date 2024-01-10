//
//  TouristListApiModel+Mapping.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

extension TouristListApiModel {
    func toDomain() -> TouristListViewModel {
        return TouristListViewModel(items: self.results.map( { $0.toDomain() }), totalPageCount: totalPages, totalItemCount: total)
    }
}

extension PlacesListApiModel {
    func toDomain() -> PlacesListItemUIModel {
        return PlacesListItemUIModel(title: self.altDescription, imagePath: self.urls?.thumb)
    }
}
