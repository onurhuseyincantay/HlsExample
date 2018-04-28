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
                let stream = StreamListManager.shared.stream(withName: assetName)
                let urlAsset = assetDownloadTask.urlAsset
                let asset = Asset(stream: stream, urlAsset: urlAsset)
                self.activeDownloadsMap[assetDownloadTask] = asset
            }
         NotificationCenter.default.post(name: .AssetPersistenceManagerDidRestoreState, object: nil)
        }
    }
    
    func downloadStream(for asset: Asset) {
        // I Don't Know what this 265_000 is ?.?
        let prefferedMediaSelection = asset.urlAsset.preferredMediaSelection
        guard let task = assetDownloadUrlSession.aggregateAssetDownloadTask(with: asset.urlAsset, mediaSelections: [prefferedMediaSelection], assetTitle: asset.stream.name, assetArtworkData: nil, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey : 265_000])else{return}
        task.taskDescription = asset.stream.name
        task.resume()
        var userInfo = Dictionary<String,Any>()
        userInfo[Asset.Keys.name] = asset.stream.name
        userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue
        userInfo[Asset.Keys.downloadSelectionDisplayName] = displayNamesForSelectedMediaOptions(prefferedMediaSelection)
        
    }
    
    func displayNamesForSelectedMediaOptions(_ mediaSelection:AVMediaSelection) -> String {
        var displayNames = ""
        guard let asset = mediaSelection.asset else {
            return displayNames
        }
        for mediaCharectiristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions{
            guard let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharectiristic),let option = mediaSelection.selectedMediaOption(in: mediaSelectionGroup)else{continue}
            if displayNames.isEmpty{
                displayNames += " " + option.displayName
            }else{
                displayNames += ", " + option.displayName
            }
        }
        return displayNames
    }
    
    func assetForStream(withName name: String) -> Asset? {
        var asset : Asset?
        for (_,assetValue) in activeDownloadsMap where name == assetValue.stream.name{
            asset = assetValue
            break
        }
        return asset
    }
    
    func localAssetForStream(withName name : String)-> Asset? {
        let userDefaults = UserDefaults.standard
        guard let localFileLocation = userDefaults.value(forKey: name) as? Data else{return nil}
        var asset : Asset?
        var bookmarkDataIsStale = false
        do{
            guard let url = try URL(resolvingBookmarkData: localFileLocation,
            bookmarkDataIsStale: &bookmarkDataIsStale) else {
                fatalError("Failed to create URL from bookmark!")
            }
            if bookmarkDataIsStale{
                fatalError("Bookmark Data is Stale")
            }
            let urlAsset = AVURLAsset(url: url)
            let stream = StreamListManager.shared.stream(withName: name)
            asset = Asset(stream: stream, urlAsset: urlAsset)
            return asset
        }catch{
            fatalError("Failed to Create Url from Bookmark with error \(error)")
        }
    }
    
    func downloadState(for asset : Asset)->Asset.DownloadState{
        if let localFileLocation = localAssetForStream(withName: asset.stream.name)?.urlAsset.url{
            if FileManager.default.fileExists(atPath: localFileLocation.path){
                return .downloaded
            }
        }
        for(_,assetValue) in activeDownloadsMap where asset.stream.name == asset.stream.name{
            return .downloading
        }
        return .notDownloaded
    }
    func deleteAsset(_ asset : Asset)  {
        let userDefaults = UserDefaults.standard
        do{
            if let localFileLocation = localAssetForStream(withName: asset.stream.name)?.urlAsset.url{
                try FileManager.default.removeItem(at: localFileLocation)
                userDefaults.removeObject(forKey: asset.stream.name)
                var userInfo = Dictionary<String,Any>()
                userInfo[Asset.Keys.name] = asset.stream.name
                userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
                NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil,userInfo: userInfo)
            }
        }catch{
            print("An error occured deleting the File \(error.localizedDescription)")
        }
    }
    func cancelDownload(for asset:Asset)  {
        var task:AVAggregateAssetDownloadTask?
        for(taskKey,assetVal) in activeDownloadsMap where asset == assetVal{
            task = taskKey
            break
        }
        task?.cancel()
    }
    
}

extension AssetPersistenceManager:AVAssetDownloadDelegate{
    
}
