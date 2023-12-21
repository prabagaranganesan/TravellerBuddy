//
//  DataTransferService.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import Foundation

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

class JSONResponseDecoder: ResponseDecoder {
    
    private let jsonDecoder = JSONDecoder()
    
    init() { }
    
    func decode<T>(_ data: Data) throws -> T where T : Decodable {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
