//
//  StreamListManager.swift
//  HlsVideoPlayerApp
//
//  Created by Onur Hüseyin Çantay on 28.04.2018.
//  Copyright © 2018 Onur Hüseyin Çantay. All rights reserved.
//

import Foundation

class StreamListManager  {
    static let shared : StreamListManager = StreamListManager()
    var streams : [Stream]!
    private var streamMap = Dictionary<String,Stream>()
    private init(){
        do{
            guard let streamsFilePath = Bundle.main.url(forResource: "Streams",withExtension:"plist")else{return}
            let data = try Data(contentsOf: streamsFilePath)
            let plistDecoder = PropertyListDecoder()
            streams = try plistDecoder.decode([Stream].self, from: data)
            for stream in streams{
                streamMap[stream.name] = stream
            }
        }catch{
            fatalError("An error occured when reading the Stream.plist File : \(error.localizedDescription)")
        }
    }
    func stream(withName name : String) ->Stream {
        guard let stream = streamMap[name] else{fatalError("Couldn't find Stream with name \(name)")}
        return stream
    }
}
