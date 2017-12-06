//
//  ApiManager.swift
//  WilFi
//
// サーバ間通信処理
//
//  Created by Tatsuya Uemura on 2017/10/26.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import Alamofire

class Server {
    static var params:[String: Any] = [
        // TODO: ユーザIDを追加する。Keychainに保存して
        "os": "ios",
        "os_version": String(UIDevice.current.systemVersion) as String,
        "app_version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String,
        "u" : Settings.sharedManager.getUserID(),
        "v" : "1" // apiバージョン
    ]

    // 接続情報を送信する。
    class func sendConnectionData(spotId:Int,type:SpotType,status:ConnectionSuccessStatus, completion:@escaping (_ flag:Bool) -> Void){
        var p = params
        let manager = ApiManager.sharedInstance
        p["sid"] = spotId
        p["ct"] = type.rawValue
        p["cs"] = status.rawValue
        manager.request(Settings.URL_POST_CONNECTION, method: .post, parameters: p, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                if let all:NSDictionary = response.result.value as? NSDictionary {
                    guard let data:NSDictionary = all["data"] as? NSDictionary else{
                        completion(false)
                        return
                    }
                    
                    guard let result:Bool = data["result"] as? Bool else{
                        completion(false)
                        return
                    }
                    completion(result)
                    return
                }
            }
            completion(false)
        })
    }

    // beaconID(minor)からWi-Fi情報を取得する
    class func getDetail(beaconId:String,spotType:SpotType,success:@escaping (_ wifiInfo:WifiInfo) -> Void,error:@escaping () -> Void){
        let p = params
        let manager = ApiManager.sharedInstance
        var url = Settings.URL_GET_INFO;
        url = String(format: url,beaconId)
        
        NSLog(url)
        manager.request(url,parameters: p).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers, completionHandler: { response in
            if response.result.isSuccess {
                if let all:NSDictionary = response.result.value as? NSDictionary {
                    guard let data:NSDictionary = all["data"] as? NSDictionary else{
                        error()
                        return
                    }

                    guard let beacon:NSDictionary = data["beacon"] as? NSDictionary else{
                        error()
                        return
                    }
                    guard let spot:NSDictionary = data["spot"] as? NSDictionary else{
                        error()
                        return
                    }

                    success(
                        WifiInfo(
                            minor:beacon["minor"] as! String,
                            spotId:spot["id"] as! Int,
                            ssid:spot["ssid"] as! String,
                            bssid:spot["bssid"] as! String,
                            spotName:spot["name"] as! String,
                            iconUrl:spot["icon_url"] as! String,
                            latitude:atof((spot["lat"] as! String)),
                            longitude:atof((spot["lng"] as! String)),
                            connectionCount:Int(spot["connection_count"] as! String)!,
                            detail:spot["description"] as! String,
                            spotType:spotType
                        )
                    )
                    return
                }
            }
            error()
        })
    }

    // spotIDからWi-Fi情報を取得する(NFC用)
    class func getDetailBySpotID(spotId:Int,success:@escaping (_ wifiInfo:WifiInfo) -> Void,error:@escaping () -> Void){
        let p = params
        let manager = ApiManager.sharedInstance
        var url = Settings.URL_GET_INFO_NFC;
        url = String(format: url,spotId)
        
        NSLog(url)
        manager.request(url,parameters: p).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers, completionHandler: { response in
            if response.result.isSuccess {
                if let all:NSDictionary = response.result.value as? NSDictionary {
                    guard let data:NSDictionary = all["data"] as? NSDictionary else{
                        error()
                        return
                    }
                    
                    guard let spot:NSDictionary = data["spot"] as? NSDictionary else{
                        error()
                        return
                    }
                    
                    success(
                        WifiInfo(
                            spotId:spot["id"] as! Int,
                            ssid:spot["ssid"] as! String,
                            bssid:spot["bssid"] as! String,
                            spotName:spot["name"] as! String,
                            iconUrl:spot["icon_url"] as! String,
                            latitude:atof((spot["lat"] as! String)),
                            longitude:atof((spot["lng"] as! String)),
                            connectionCount:Int(spot["connection_count"] as! String)!,
                            detail:spot["description"] as! String,
                            spotType:SpotType.NFC
                        )
                    )
                    return
                }
            }
            error()
        })
    }

    // Wi-Fi接続情報を取得する
    class func getConnectionData(spotId:Int,success:@escaping (_ wifiData:WifiConnectData) -> Void,error:@escaping () -> Void){
        let p = params
        let manager = ApiManager.sharedInstance
        var url = Settings.URL_GET_PASS;
//        url = String(format: url,spotId,WFEncrypt.getIVbase64String().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        url = String(format: url,spotId,WFEncrypt.getIVbase64String().addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)

        
        NSLog(url)
        manager.request(url,parameters: p).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers, completionHandler: { response in
            if response.result.isSuccess {
                if let all:NSDictionary = response.result.value as? NSDictionary {
                    
                    guard let data:NSDictionary = all["data"] as? NSDictionary else{
                        error()
                        return
                    }

                    guard let join_type:NSDictionary = data["join_type"] as? NSDictionary else{
                        error()
                        return
                    }

                    guard let security_type:NSDictionary = data["security_type"] as? NSDictionary else{
                        error()
                        return
                    }

                    do {
//                        let dec = try WFEncrypt.decrypt(value: enc)
                        
//                        print("encode pass:" , data["pass"] as! String)
//                        print("iv:", WFEncrypt.getIVbase64String())
//                        print("iv encode(urlQueryAllowed):",WFEncrypt.getIVbase64String().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
//                        print("iv encode(alphanumerics):",WFEncrypt.getIVbase64String().addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!)

                        guard let passphrase:String = try WFEncrypt.decrypt(value: data["pass"] as! String) else {
                            error()
                            return
                        }
//                        print(passphrase)
                        success(
                            WifiConnectData(
                                spotId:data["id"] as! Int,
                                ssid:data["ssid"] as! String,
                                passphrase:passphrase,
                                lifeTime:data["lifetime"] as! Int,
                                joinOnce:join_type["join_once"] as! Bool,
                                isWep:security_type["wep"] as! Bool
                            )
                        )

                    }catch{
                        NSLog("デコードのエラー")
                    }
//                    let passphrase:String = WFEncrypt.decrypt(value: data["pass"] as! String)!
                    
                    return
                }
            }
            error()
        })
    }

    // 周辺のWi-Fi一覧を取得する
    // TODO: ビーコンで取得したものを除く必要があるな。。
    class func getOtherWifisList(location:CLLocationCoordinate2D,success:@escaping (_ wifiInfos:[WifiInfo]) -> Void,error:@escaping () -> Void){
        let p = params
        let manager = ApiManager.sharedInstance
        var url = Settings.URL_GET_OTHER_WIFIS;
        url = String(format: url,location.latitude,location.longitude)
        
        var wifiInfos:[WifiInfo] = []
        
        manager.request(url,parameters: p).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers, completionHandler: { response in
            if response.result.isSuccess {
                if let all:NSDictionary = response.result.value as? NSDictionary {
                    
                    guard let data:NSDictionary = all["data"] as? NSDictionary else{
                        error()
                        return
                    }

                    guard let spots:NSArray = data["spots"] as? NSArray else{
                        error()
                        return
                    }

                    spots.forEach({ (list) in
                        let d:NSDictionary = (list as? NSDictionary)!
                        wifiInfos.append(
                            WifiInfo(
                                spotId:d["id"] as! Int,
                                ssid:d["ssid"] as! String,
                                bssid:d["bssid"] as! String,
                                spotName:d["name"] as! String,
                                iconUrl:d["icon_url"] as! String,
                                latitude:atof((d["lat"] as! String)),
                                longitude:atof((d["lng"] as! String)),
                                connectionCount:Int(d["connection_count"] as! String)!,
                                detail:d["description"] as! String,
                                spotType:SpotType.Location
                            )
                        )

                    })
                    
                    // 現在地から近い順にソート
                    wifiInfos.sort(by: { (a ,b) -> Bool in
                        return a.distance < b.distance
                    })
                    
                    success(wifiInfos)

//                    if let list:NSArray = all["list"] as? NSArray {
//                        list.forEach({ (data) in
//                            let d:NSDictionary = (data as? NSDictionary)!
//
//                            wifiInfos.append(
//                                WifiInfo(
//                                    spotId:d["spot_id"] as! Int,
//                                    ssid:d["ssid"] as! String,
//                                    bssid:d["bssid"] as! String,
//                                    spotName:d["spot_name"] as! String,
//                                    iconUrl:d["icon_url"] as! String,
//                                    latitude:atof((d["lat"] as! String)),
//                                    longitude:atof((d["lng"] as! String)),
//                                    spotType:SpotType.Location
//                                )
//                            )
//                        })
//                        success(wifiInfos)
//                    }
                    return
                }
            }
            error()
        })
    }

    
    // https://qiita.com/shtnkgm/items/d9b78365a12b08d5bde1
    
    // ビーコンのWi-Fi情報一覧を取得する
    class func doMultiAsyncGetBeaconSpotDetail(beaconIDs:[String]) {
//        NotificationCenter.default.post(name: Settings.WifiListStartNotification,
//                                        object: nil)

        let dispatchGroup = DispatchGroup()
        // TODO: 並列にして、結果を並び変えるのが早いのか？直列が早いのか？
//        let dispatchQueue = DispatchQueue(label: "get.detail.queue", attributes: .concurrent) // 並列
        let dispatchQueue = DispatchQueue(label: "get.detail.queue") // 直列

        var wifis: [WifiInfo] = []

        // 複数の非同期処理を実行
        stride(from: 0, to: beaconIDs.count, by: 1).forEach {
            let beaconId = beaconIDs[$0]
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                self.getDetail(
                    beaconId: beaconId,
                    spotType: SpotType.Beacon,
                    success: {(wifiInfo) in
                        wifis.append(wifiInfo)
                        // print("CCC:",wifiInfo.description);
                    dispatchGroup.leave()
                },error: {() in
                    dispatchGroup.leave()
                })
            }
        }
        
        // 現在地から近い順にソート
        wifis.sort(by: { (a ,b) -> Bool in
            return a.distance < b.distance
        })

        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            NotificationCenter.default.post(name: Settings.WifiListChangeNotification,
                                            object: wifis)
            NSLog("All Process Done!")
        }
    }
}

class ApiManager {
    static let sharedInstance: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
#if arch(i386) || arch(x86_64)
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData // キャッシュを使わない。
#else
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy // デフォルト
#endif
        configuration.timeoutIntervalForRequest  = 30
        configuration.timeoutIntervalForResource = 30
        return SessionManager(configuration: configuration)
    }()
}
