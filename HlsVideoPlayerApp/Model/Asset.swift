//
//  Asset.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import AVFoundation

class Asset {
    
    var urlAsset : AVURLAsset
    let stream : Stream
    
    init(stream : Stream,urlAsset : AVURLAsset) {
        self.urlAsset = urlAsset
        self.stream = stream
    }
    
}
extension Asset{
    enum DownloadState : String {
        case notDownloaded
        case downloading
        case downloaded
    }
}
extension Asset{
    struct Keys {
        static let name = "AssetNameKey"
        static let percentDownloaded = "AssetPercentDownloadKey"
        static let downloadState = "AssetDownloadStateKey"
        static let downloadSelectionDisplayName = "AssetDownloadSelectionDisplayNameKey"
    }
}

extension Asset: Equatable{
    static func ==(lhs:Asset,rhs : Asset) -> Bool{
        return (lhs.stream == rhs.stream) && (lhs.urlAsset == rhs.urlAsset)
    }
}

