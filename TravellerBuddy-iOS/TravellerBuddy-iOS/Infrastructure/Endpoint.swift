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
         responseDecoder: ResponseDecoder,
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

enum RequestGenerationError: Error {
    case components
}

extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()
        
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value:  "\($0.value)") )
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }
    
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }
        
        if !bodyParamters.isEmpty {
            urlRequest.httpBody = encode(bodyParameters: bodyParamters)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }

    private func encode(bodyParameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: bodyParameters)
    }
}
