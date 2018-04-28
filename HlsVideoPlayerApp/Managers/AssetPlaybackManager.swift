//
//  AssetPlaybackManager.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import UIKit
import AVFoundation

class AssetPlaybackManager: NSObject {
    static let sharedManager = AssetPlaybackManager()
    weak var delegate : AssetPlaybackDelegate?
    
    private let player = AVPlayer()
    private var readyforPlayback = false
    private var playerItemObserver : NSKeyValueObservation?
    private var urlAssetObserver : NSKeyValueObservation?
    private var playerObserver : NSKeyValueObservation?
    
    private var playerItem : AVPlayerItem?{
        willSet{
            guard let playerItemObserver = playerItemObserver else { return }
            playerItemObserver.invalidate()
        }
        didSet{
            playerItemObserver = playerItem?.observe(\AVPlayerItem.status, options: [.new, .initial]) { [weak self] (item, _) in
                guard let strongSelf = self else{return}
                if item.status == .readyToPlay{
                    if !strongSelf.readyforPlayback{
                        strongSelf.readyforPlayback = true
                        strongSelf.delegate?.streamPlaybackManager(strongSelf, playerReadyToPlay: strongSelf.player)
                    }else if item.status == .failed{
                        let error = item.error
                        print("Error : \(String(describing: error?.localizedDescription))")
                    }
                }
            }
        }
    }
    
    private var asset : Asset?{
        willSet{
            guard let urlAssetObserver = urlAssetObserver else { return }
            urlAssetObserver.invalidate()
        }
        didSet{
            if let asset = asset{
                urlAssetObserver = asset.urlAsset.observe(\AVURLAsset.isPlayable, options: [.new, .initial]) { [weak self] (urlAsset, _) in
                    guard let strongSelf = self, urlAsset.isPlayable == true else { return }
                    strongSelf.playerItem = AVPlayerItem(asset: urlAsset)
                    strongSelf.player.replaceCurrentItem(with: strongSelf.playerItem)
            }
            }else{
                playerItem = nil
                player.replaceCurrentItem(with: nil)
                readyforPlayback = false
            }
        }
    }
    private override init() {
        super.init()
        playerObserver = player.observe(\AVPlayer.currentItem, options: [.new]) { [weak self] (player, _) in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.streamPlaybackManager(strongSelf, playerCurrentItemDidChange: player)
        }
        
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    deinit {
        /// Remove any KVO observer.
        playerObserver?.invalidate()
    }
    func setAssetForPlayback(_ asset: Asset?) {
        self.asset = asset
    }
    
}
protocol AssetPlaybackDelegate : class {
    func streamPlaybackManager(_ streamPlaybackManager:AssetPlaybackManager,playerReadyToPlay player: AVPlayer)
    func streamPlaybackManager(_ streamPlaybackManager:AssetPlaybackManager,playerCurrentItemDidChange player : AVPlayer)
}
