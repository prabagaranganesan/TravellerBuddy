//
//  NetworkConfig.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import Foundation

protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

final class ApiDataNetworkConfig: NetworkConfigurable {
    var baseURL: URL
    var headers: [String : String]
    var queryParameters: [String : String]
    
    init(baseURL: URL,
         headers: [String : String],
         queryParameters: [String : String]) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
