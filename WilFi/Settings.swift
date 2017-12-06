//
//  Settings.swift
//  WilFi
//
// 設定情報
//
//  Created by Tatsuya Uemura on 2017/10/13.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

/// IconFont名
enum IconFont: String {
    
    /// close
    case close = "\u{e900}"
    
    /// reload
    case reload = "\u{e901}"
    
    /// setting
    case setting = "\u{e902}"
    
    /// users
    case users = "\u{e903}"
    
    /// nfc_touch
    case nfc_touch = "\u{e904}"
}

/// debugPushのレベル
enum WFDebugPushLevel: Int {
    // OFF
    case off = 0
    // 並(ライト) Waringレベルとする
    case level1 = 1
    // 上(ミドル) Debugレベルとする
    case level2 = 2
    // 特上(ヘビー) Traceレベルとする
    case level3 = 3
}

class Settings {
    static let sharedManager = Settings()
    static let APP_ID = 0
    
    // BluetoothのON／OFF通知
    static let BluetoothNotification = Notification.Name("com.fancs.wilfi.BluetoothNotification")
    // CLAuthorizationStatusの変化通知
    static let LocationStatusNotification = Notification.Name("com.fancs.wilfi.LocationStatusNotification")

    // Wifiリストの更新通知(取得完了)
    static let WifiListChangeNotification = Notification.Name("com.fancs.wilfi.WifiListChangeNotification")
    // Wifi接続通知
    static let WifiConnectedNotification = Notification.Name("com.fancs.wilfi.WifiConnectedNotification")
    // GPSからのWifiリストの更新通知(取得完了)
    static let WifiListChangeLocationNotification = Notification.Name("com.fancs.wilfi.WifiListChangeLocationNotification")
    // GPSからのWifiリストの更新通知(取得なし)
    static let WifiListNotChangeLocationNotification = Notification.Name("com.fancs.wilfi.WifiListNotChangeLocationNotification")

    // Nend動画広告閲覧タイムアウト
    static let NendTimeLimitErrorNotification = Notification.Name("com.fancs.wilfi.NendTimeLimitErrorNotification")
    
    // Wifiリスト取得開始文言(beacon)
    static let WIFI_LIST_START_WORD = "接続可能なWi-Fiが表示されます"

    // Wifiリスト取得開始文言(周辺)
    static let OTHER_WIFI_LIST_START_WORD = "周辺のWi-Fiが表示されます"

    // 接続成功情報送信URL(NFC)
    static let URL_POST_CONNECTION            = "https://watchdog.adcrops.net/wilfi/api/spot/connection_success"

    // Wifiスポット情報取得URL
//    static let URL_GET_INFO            = "https://watchdog.adcrops.net/wilfi/list/v2/%@.json"
    static let URL_GET_INFO            = "https://watchdog.adcrops.net/wilfi/api/spot/beacon?bmi=%@"
    
    // Wifiスポット情報取得URL(NFC)
    static let URL_GET_INFO_NFC            = "https://watchdog.adcrops.net/wilfi/api/spot/nfc?sid=%d"

    // Wifi接続情報取得URL
//    static let URL_GET_PASS            = "https://watchdog.adcrops.net/wilfi/pass/v2/%@.json"
    static let URL_GET_PASS            = "https://watchdog.adcrops.net/wilfi/api/spot/connect?sid=%d&iv=%@"

    // 周辺のWifiスポット情報取得URL
//    static let URL_GET_OTHER_WIFIS      = "https://watchdog.adcrops.net/wilfi/list/v2/1other.json?lat=%f&lng=%f&range=0.02"
    static let URL_GET_OTHER_WIFIS      = "https://watchdog.adcrops.net/wilfi/api/spot/latlng?lat=%f&lng=%f&range=0.03"

    // NFC読み取り後のWait時間(秒)
    static let NFC_FINISH_WAIT_TIME      = 3.0
    
    private let ud = UserDefaults.standard

    // NEND
    static let NEND_API_KEY = "c2e3ea3e87d521c7cfe4adf6b6037888e01bc8fe"
    static let NEND_SPOT_ID = "821625"
    // NEND 広告をみなかった場合に接続を切断する時間(秒)
#if arch(i386) || arch(x86_64)
    static let NEND_REWARD_TIME_LIMIT = 45
#else
    static let NEND_REWARD_TIME_LIMIT = 120
#endif
    // NEND 広告取得をタイムアウトエラーとする時間(秒)
    static let NEND_REWARD_TIMEOUT_TIME = 15
    
    // キーチェーン関連
    private let KEY_CHAIN_SERVICE_NAME = "com.fancs.wilfi"
    private let KEY_CHAIN_USER_ID_KEY = "KEY_CHAIN_USER_ID_KEY"
    
    // GoogleMapのURLスキーム
    static let GOOGLE_MAP_URL_SCHEME = "comgooglemaps://"

    /// ユーザIDを取得する
    ///
    /// - Returns: UserID
    func getUserID() -> String {
        let keychain = Keychain(service: KEY_CHAIN_SERVICE_NAME)
        do {
            let hasUID:Bool = try keychain.contains(KEY_CHAIN_USER_ID_KEY)
            if(hasUID) {
                NSLog("hasUserID")
                return (try keychain.getString(KEY_CHAIN_USER_ID_KEY))!
            }else{
                let uuid = NSUUID().uuidString
                NSLog("createUserID:" + uuid)
                try keychain.set(uuid, key: KEY_CHAIN_USER_ID_KEY)
//                keychain.synchronizable
                return uuid
            }
        }catch{
            
        }
        return ""
    }
 
    private let UD_CONNECT_DATA_KEY = "WILFI_CONNECTED_DATA"
    
    // 最終接続先のWi-Fi情報取得
    func getUdWifiData() ->  WifiConnectData? {
        NSLog("getUdWifiData")
        guard let data = UserDefaults.standard.object(forKey: UD_CONNECT_DATA_KEY) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? WifiConnectData
    }
    
    // 最終接続先のWi-Fi情報保存
    func setUdWifiData(wifi:WifiConnectData) {
        NSLog("setUdWifiData:\(wifi.ssid)")
        let sendNsData: NSData = NSKeyedArchiver.archivedData(withRootObject: wifi) as NSData
        UserDefaults.standard.set(sendNsData as AnyObject, forKey:UD_CONNECT_DATA_KEY)
        UserDefaults.standard.synchronize()
//        print(UserDefaults.standard.dictionaryRepresentation())
    }
    
    /// 保存されている接続先Wi-Fi情報を削除
    func resetUdWifiData() {
        NSLog("resetUdWifiData")
        UserDefaults.standard.removeObject(forKey: UD_CONNECT_DATA_KEY)
        UserDefaults.standard.synchronize()
//        print(UserDefaults.standard.dictionaryRepresentation())
    }
}
