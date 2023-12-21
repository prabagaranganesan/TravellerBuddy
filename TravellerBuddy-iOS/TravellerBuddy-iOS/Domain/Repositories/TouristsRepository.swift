//
//  TouristsRepository.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

struct TouristQuery: Equatable {
    let query: String
}

protocol TouristsRepository  {
    func fetchTouristsList(
        query: TouristQuery,
        page: Int,
        cached: @escaping (TouristListViewModel) -> Void,
        completion: @escaping (Result<TouristListViewModel, Error>) -> Void
    ) -> Cancellable?
}
