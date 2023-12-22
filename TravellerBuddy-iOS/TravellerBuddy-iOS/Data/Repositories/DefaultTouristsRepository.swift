//
//  DefaultTouristsRepository.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 21/12/23.
//

import Foundation

final class DefaultTouristsRepository: TouristsRepository {
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    func fetchTouristsList(query: TouristQuery, page: Int, cached: @escaping (TouristListViewModel) -> Void, completion: @escaping (Result<TouristListViewModel, Error>) -> Void) -> Cancellable? {
        let endpoint = APIEndpoints.getTouristsList(query: query.query, pageNumber: page)
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        task.networkTask = dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                completion(.success(response.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

//TODO: check is it really needed that can't we directly just return dataTask
class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
