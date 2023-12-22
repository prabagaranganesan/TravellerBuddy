//
//  AppDelegate.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 20/12/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appDIContainer = AppDIContainer()
    private var rootCoordinator: RootCoordinator?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        
        rootCoordinator = RootCoordinator(navigationController: navigationController, appDIController: appDIContainer)
        rootCoordinator?.start()
        window?.makeKeyAndVisible()
        return true
    }
}

