//
//  Extensions.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import Foundation

extension Notification.Name{
    static let AssetDownloadProgress = Notification.Name(rawValue: "AssetDownloadProgressNotification")
    static let AssetDownloadStateChanged = Notification.Name(rawValue: "AssetDownloadStateChangedNotification")
    static let AssetPersistenceManagerDidRestoreState = Notification.Name(rawValue: "AssetPersistenceManagerDidRestoreStateNotification")
    static let AssetListManagerDidLoad = Notification.Name(rawValue: "AssetListManagerDidLoadNotification")
}
