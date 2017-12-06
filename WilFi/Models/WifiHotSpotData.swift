//
//  WifiHotSpotData.swift
//  WilFi
//
// 接続中のスポットデータ
//
//  Created by Tatsuya Uemura on 2017/10/30.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation

class WifiHotSpotData: NSObject {
    var ssid        : String
    var bssId       : String
    var secure      : Bool
    var autoJoined     : Bool
    var signalStrength : Double
    
    init(
        ssid            : String,
        bssId           : String,
        secure          : Bool,
        autoJoined      : Bool,
        signalStrength  : Double
        ){
        self.ssid     = ssid
        self.bssId   = bssId
        self.secure    = secure
        self.autoJoined = autoJoined
        self.signalStrength = signalStrength
    }
    init(
        ssid            : String,
        bssId           : String
        ){
        self.ssid     = ssid
        self.bssId   = bssId
        self.secure    = false
        self.autoJoined = false
        self.signalStrength = 0
    }

    override var description: String {
        get
        {
            return "ssid:\(self.ssid) ,bssId:\(self.bssId)"
        }
    }
    
}

