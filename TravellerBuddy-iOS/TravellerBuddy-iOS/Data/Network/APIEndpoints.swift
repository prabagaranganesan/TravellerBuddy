//
//  APIEndpoints.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

struct APIEndpoints {
    
    static func getTouristsList(pageNumber: Int) -> Endpoint<TouristListApiModel> {
        let queryParameters = ["page": "\(pageNumber)",
                               "client_id": Constant.Api.apiKey
                              ]
        
        return Endpoint(path: "/search/photos",
                        method: .get,
                        headerParameters: ["Accept": "application/json"],
                        queryParameters: queryParameters,
                        bodyParamters: [:])
    }
}