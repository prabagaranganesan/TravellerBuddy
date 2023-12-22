//
//  TouristListApiModel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

struct TouristListApiModel: Decodable {
    let results: [PlacesListApiModel]
}

struct PlacesListApiModel: Decodable {
    let altDescription: String?
    let urls: URLModel?
    
    struct URLModel: Codable {
        let regular: String?
        let small: String?
        let full: String?
        let thumb: String?
    }
}
