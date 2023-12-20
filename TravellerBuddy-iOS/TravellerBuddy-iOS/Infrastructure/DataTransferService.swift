//
//  DataTransferService.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

//TODO: move this request related to different file
enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
}

protocol ResponseDecoder {
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

protocol DataTransferService {
     typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                       completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    func request<E: ResponseRequestable>(with endpoint: E,
                                         completion: @escaping CompletionHandler<Void>) -> NetworkCancellable? where E.Response == Void
}

final class DefaultDataTransferService: DataTransferService {
    
    private let networkService: NetworkService
    private let errorResolver: DatatransferErrorResolver
    
    init(networkService: NetworkService,
         errorResolver: DatatransferErrorResolver) {
        self.networkService = networkService
        self.errorResolver = errorResolver
    }
    
    func request<T, E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where T : Decodable, T == E.Response, E : ResponseRequestable {
        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                completion(result)
            case .failure(let error):
                let error = self.resolve(networkError: error)
                completion(.failure(error))
            }
        }
    }
    
    func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                let error = self.resolve(networkError: error)
                completion(.failure(error))
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}

protocol DatatransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

final class DefaultDataTransferErrorResolver: DatatransferErrorResolver {
    
    init() { }
    
    func resolve(error: NetworkError) -> Error {
        return error
    }
}
