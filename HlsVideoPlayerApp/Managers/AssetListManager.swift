//
//  AssetListManager.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import Foundation
import AVFoundation
class AssetListManager: NSObject {
    static let sharedManager = AssetListManager()
    private var assets = [Asset]()
    private override init() {
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAssetPersistenceManagerDidRestoreState(_:)), name: .AssetPersistenceManagerDidRestoreState, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self,name: .AssetPersistenceManagerDidRestoreState,object:nil)
    }
    func numberOfAssets() -> Int{
        return assets.count
    }
    func asset(at index:Int) -> Asset {
        return assets[index]
    }
    @objc func handleAssetPersistenceManagerDidRestoreState(_ notification : Notification)  {
        DispatchQueue.main.async {
            for stream in StreamListManager.shared.streams{
                if let asset = AssetPersistenceManager.sharedManager.assetForStream(withName: stream.name){
                    self.assets.append(asset)
                }else{
                    let urlAsset = AVURLAsset(url: URL(string: stream.playlistURL)!)
                    let asset = Asset(stream: stream, urlAsset: urlAsset)
                    self.assets.append(asset)
                }
                NotificationCenter.default.post(name: .AssetListManagerDidLoad, object: self)
            }
        }
    }
}
