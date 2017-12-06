//
//  WifiData.swift
//  WilFi
//
// Wifi接続情報
//
//  Created by Tatsuya Uemura on 2017/10/13.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation

// 変数の宣言時にデータ型の最後に"!"をつけるとオプショナル型となる。
// http://d.pr/i/bVYeiS

// データ型の参考
// https://camo.qiitausercontent.com/1a7af99435e5899ec36727f4f6f961fa50464e1d/68747470733a2f2f71696974612d696d6167652d73746f72652e73332e616d617a6f6e6177732e636f6d2f302f35383430342f63303735363663362d633139652d376661392d363133362d6332616539616565376162312e706e67

class WifiConnectData: NSObject,NSCoding {
    
    var spotId          : Int
    var ssid            : String
    var passphrase      : String
    var lifeTime        : Int
    var joinOnce        : Bool
    var isWep           : Bool
    init(
        spotId              : Int,
        ssid                : String,
        passphrase          : String,
        lifeTime            : Int,
        joinOnce            : Bool,
        isWep               : Bool
        ){
        self.spotId         = spotId
        self.ssid           = ssid
        self.passphrase     = passphrase
        self.lifeTime       = lifeTime / 86400 // サーバ側の管理は秒
        self.joinOnce       = joinOnce
        self.isWep          = isWep
    }
    init(
        ssid                : String
        ){
        self.spotId         = 0000000000
        self.ssid           = ssid
        self.passphrase     = ""
        self.lifeTime       = 1
        self.joinOnce       = false
        self.isWep          = false
    }

    override var description: String {
        get
        {
            return "spotId:\(self.spotId) ,ssid:\(self.ssid) ,passphrase:\(passphrase) ,lifeTime:\(lifeTime) ,joinOnce:\(joinOnce) ,isWep:\(isWep)"
        }
    }
    
    //シリアライズ
    func encode(with aCoder: NSCoder) {
        aCoder.encode(spotId, forKey: "spotId")
        aCoder.encode(ssid, forKey: "ssid")
        // TODO: パスフレーズは保存しない方がいいか。
//        aCoder.encode(passphrase, forKey: "passphrase")
        aCoder.encode(lifeTime, forKey: "lifeTime")
        aCoder.encode(joinOnce, forKey: "joinOnce")
        aCoder.encode(isWep, forKey: "isWep")
        NSLog("encode end.")
    }

    //デシリアライズ
    required init(coder: NSCoder) {
        self.spotId = coder.decodeInteger(forKey: "spotId")
        self.ssid = coder.decodeObject(forKey: "ssid") as! String
        // TODO: パスフレーズは保存しない方がいいか。
//        self.passphrase = coder.decodeObject(forKey: "passphrase") as! String
        self.passphrase = ""
        self.lifeTime = coder.decodeInteger(forKey: "lifeTime")
        self.joinOnce = coder.decodeBool(forKey: "joinOnce")
        self.isWep = coder.decodeBool(forKey: "isWep")
        NSLog("decode end.")
    }
    
    
}
