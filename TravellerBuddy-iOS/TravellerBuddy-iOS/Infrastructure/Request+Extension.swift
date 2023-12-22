//
//  Request.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
}

protocol ResponseDecoder {
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
    func decode<T: Decodable>(_ data: Data) throws -> T
}

protocol NetworkCancellable {
    func cancel()
}

protocol Requestable {
    var path: String { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParameters: [String: Any] { get }
    var bodyParamters: [String: Any] { get }
    var isFullPath: Bool { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

protocol ResponseRequestable: Requestable {
    associatedtype Response
    var responseDecoder: ResponseDecoder { get }
}

enum RequestGenerationError: Error {
    case components
    case invalidURL
}

extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        guard let url = config.baseURL else { throw RequestGenerationError.invalidURL }
        let baseURL = url.absoluteString.last != "/" ? url.absoluteString + "/" : url.absoluteString
        
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
