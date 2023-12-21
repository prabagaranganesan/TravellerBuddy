//
//  Endpoint.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import Foundation

class Endpoint<R>: ResponseRequestable {
    
    typealias Response = R
    
    let path: String
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParameters: [String: Any]
    let bodyParamters: [String: Any]
    let isFullPath: Bool
    let responseDecoder: ResponseDecoder
    
    init(path: String,
         method: HTTPMethodType,
         headerParameters: [String: String],
         queryParameters: [String: Any],
         bodyParamters: [String: Any],
         responseDecoder: ResponseDecoder = JSONResponseDecoder(),
         isFullPath: Bool = false) {
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParameters = queryParameters
        self.bodyParamters = bodyParamters
        self.responseDecoder = responseDecoder
        self.isFullPath = isFullPath
    }
}

