//
//  WifiInfo.swift
//  WilFi
//
// Wifiスポットの情報
//
//  Created by Tatsuya Uemura on 2017/10/26.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit

enum SpotType : Int {
    case Beacon     = 1     // ビーコン
    case NFC        = 2     // NFC
    case Location   = 3     // 周辺
}

// 接続情報送信時のステータス
// 1:接続成功、100:広告閲覧途中離脱、200:その他
enum ConnectionSuccessStatus : Int {
    case Success = 1
    case AdWithdrawal = 100
    case Other = 200
}

class WifiInfo: NSObject {
    var minor           : String    // beaconのマイナー値
    var spotId          : Int    // スポットID
    var ssid            : String    // SSID
    var bssid           : String    // BSSID
    var spotName        : String    // スポット名
    var iconUrl         : String    // アイコンURL
    var latitude        : Double    // 緯度
    var longitude       : Double    // 経度
    var distance        : Int       // 距離(m)
    var connectionCount : Int   // 接続数
    var detail          : String // 説明分
    var spotType        : SpotType  // 種別

    // beacon用
    init(
        minor           : String,
        spotId          : Int,
        ssid            : String,
        bssid           : String,
        spotName        : String,
        iconUrl         : String,
        latitude        : Double,
        longitude       : Double,
        connectionCount : Int,
        detail          : String,
        spotType        : SpotType
        ){
        self.minor              = minor
        self.spotId             = spotId
        self.ssid               = ssid
        self.bssid              = bssid
        self.spotName           = spotName
        self.iconUrl            = iconUrl
        self.latitude           = latitude
        self.longitude          = longitude
        self.connectionCount    = connectionCount
        self.detail             = detail
        self.spotType           = spotType
        self.distance           = 0
    }
    // Other用
    init(
        spotId          : Int,
        ssid            : String,
        bssid           : String,
        spotName        : String,
        iconUrl         : String,
        latitude        : Double,
        longitude       : Double,
        connectionCount : Int,
        detail          : String,
        spotType        : SpotType
        ){
        self.spotId             = spotId
        self.ssid               = ssid
        self.bssid              = bssid
        self.spotName           = spotName
        self.iconUrl            = iconUrl
        self.latitude           = latitude
        self.longitude          = longitude
        self.connectionCount    = connectionCount
        self.detail             = detail
        self.spotType           = spotType
        self.distance           = 0
        self.minor              = ""

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        guard (appDelegate.myLocation != nil) else {
            return
        }
        let d:Double = appDelegate.myLocation.distance(from: CLLocation(latitude: self.latitude, longitude: self.longitude))
        self.distance   = Int(d)
    }

    override var description: String {
        get
        {
            return "spotId:\(self.spotId) ,spotType:\(self.spotType) ,minor:\(self.minor) ,ssid:\(self.ssid) ,bssid:\(self.bssid),spotName:\(self.spotName) ,iconUrl:\(iconUrl) ,latitude:\(latitude) ,longitude:\(longitude) ,connectionCount:\(self.connectionCount) ,detail:\(self.detail),distance:\(distance)"
        }
    }
    
}
