//
//  APIEndpoints.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

struct APIEndpoints {
    
    static func getTouristsList(query: String, pageNumber: Int) -> Endpoint<TouristListApiModel> {
        let queryParameters = ["page": "\(pageNumber)",
                               "client_id": Constant.Api.apiKey,
                               "query": query
                              ]
        
        return Endpoint(path: "search/photos",
                        method: .get,
                        headerParameters: ["Accept": "application/json"],
                        queryParameters: queryParameters,
                        bodyParamters: [:])
    }
    
    static func getPlacesImage(path: String) -> Endpoint<Data> {
        return Endpoint(path: path, method: .get, headerParameters: [:], queryParameters: [:], bodyParamters: [:], isFullPath: true)
    }
}
