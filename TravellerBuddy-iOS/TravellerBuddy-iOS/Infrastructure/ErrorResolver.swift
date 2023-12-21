//
//  ErrorResolver.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
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

protocol DatatransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

final class DefaultDataTransferErrorResolver: DatatransferErrorResolver {
    
    init() { }
    
    func resolve(error: NetworkError) -> Error {
        return error
    }
}
