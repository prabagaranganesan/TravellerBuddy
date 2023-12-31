//
//  Models.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 31/12/23.
//

import Foundation
import MapKit

struct SearchResultCellViewModel {
    let title: String
    let subTitle: String
}


extension MKLocalSearchCompletion {
    
    func toDomain() -> SearchResultCellViewModel {
        return SearchResultCellViewModel(title: self.title, subTitle: subtitle)
    }
}
