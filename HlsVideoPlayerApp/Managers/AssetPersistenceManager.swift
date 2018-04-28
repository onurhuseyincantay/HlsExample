//
//  AssetPersistenceManager.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import UIKit
import AVFoundation
class AssetPersistenceManager: NSObject {
    
    /// Singleton
    static let sharedManager = AssetPersistenceManager()
    
    private var didRestorePersistenceManager = false
    
    fileprivate var assetDownloadUrlSession : AVAssetDownloadURLSession!
    fileprivate var activeDownloadsMap = [AVAggregateAssetDownloadTask: Asset]()
    fileprivate var willDownloadToUrlMap = [AVAggregateAssetDownloadTask: URL]()
    
    override private init() {
        super.init()
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "AAPL-Identifier")
        assetDownloadUrlSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: .main)
    }
    func restorePersistenceManager() {
        guard !didRestorePersistenceManager else {return}
        didRestorePersistenceManager = true
        assetDownloadUrlSession.getAllTasks { (taskArray) in
            for task in taskArray{
                guard let assetDownloadTask = task as? AVAggregateAssetDownloadTask,let assetName = task.taskDescription else{
                    return
                }
                
            }
        }
    }
    
}

extension AssetPersistenceManager:AVAssetDownloadDelegate{
    
}
