//
//  AppDIContainer.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import Foundation

final class AppDIContainer {
    lazy var appConfiguration = AppConfiguration()
    
    //MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL), headers: [:], queryParameters: [
            "language": NSLocale.preferredLanguages.first ?? "en"
        ])

        let apiDataNetwork = DefaultNetworkService(config: config, sessionManager: DefaultSessionManager())
        return DefaultDataTransferService(networkService: apiDataNetwork, errorResolver: DefaultDataTransferErrorResolver())
    }()
}
