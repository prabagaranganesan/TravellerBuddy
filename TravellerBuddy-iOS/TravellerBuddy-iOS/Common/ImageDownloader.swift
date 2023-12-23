//
//  ImageDownloader.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 23/12/23.
//

import Foundation
import UIKit

//TODO: move to common constant file
enum ImageDownloaderConstants {
    static let diskPath = "ImageDownloadCache"
    static let memoryCacheSize = 20 * 1024 * 1024
    static let discCacheSize = 100 * 1024 * 1024
    
}

public class ImageDownloader {
    var currentActivitiesCount = 0
    let session: URLSession
    let urlCache = URLCache(memoryCapacity: ImageDownloaderConstants.memoryCacheSize, diskCapacity: ImageDownloaderConstants.discCacheSize, diskPath: ImageDownloaderConstants.diskPath)
    
    private let httpRedirectionStatusCode: Set<Int> = [301, 302, 307, 308]
    
    init() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
        sessionConfiguration.urlCache = urlCache
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    @discardableResult
    func download(with url: URL, completed: @escaping (Bool, Data?, Error?) -> Void) -> URLSessionDataTask? {
        let urlRequest = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
        
        if let cacheData = cachedResponse(for: urlRequest) {
            completed(true, cacheData, nil)
            return nil
        }
        
        DispatchQueue.main.async(execute: addActivity)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            DispatchQueue.main.async(execute: self.removeActivity)
            if let error = error {
                completed(false, nil, error)
            } else if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
                completed(false, data, nil)//TODO: check do we need to pass error here
            } else {
                completed(true, data, nil)
            }
        }
        task.resume()
        return task
    }
    
    private func cachedResponse(for urlRequest: URLRequest) -> Data? {
        guard let cache = urlCache.cachedResponse(for: urlRequest) else { return nil }
        if let httpResponse = cache.response as? HTTPURLResponse,
           self.httpRedirectionStatusCode.contains(httpResponse.statusCode),
           let redirectionURLString = httpResponse.allHeaderFields["Location"] as? String,
           let redirectionURL = URL(string: redirectionURLString) {
            let urlRequest = URLRequest(url: redirectionURL, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0)
            return urlCache.cachedResponse(for: urlRequest)?.data
        } else {
            return cache.data
        }
        
    }
    
    private func addActivity() {
        if currentActivitiesCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        currentActivitiesCount += 1
    }
    
    private func removeActivity() {
        if currentActivitiesCount == 0 {
            return
        }
        
        currentActivitiesCount -= 1
        if currentActivitiesCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
