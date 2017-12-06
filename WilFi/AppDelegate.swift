//
//  AppDelegate.swift
//  WilFi
//
// AppDelegate
//
//  Created by Tatsuya Uemura on 2017/10/13.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import UserNotifications

import CoreBluetooth
import SVProgressHUD

import CoreLocation

import Reachability
//import CoreMotion

//import Puree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CBPeripheralManagerDelegate,UNUserNotificationCenterDelegate,CLLocationManagerDelegate,TbBTManagerDelegate {

    // TODO: アプリのデバッグログをサーバに送る様にしよう。
    // http://techlife.cookpad.com/entry/2014/12/25/103957
    
    
//    public func print(items: Any..., separator: String, terminator: String) {
    
//    }
    // リリースビルドでprint, debugPrintを無効化
//    func print(_ items: Any..., separator: String, terminator: String) {
//        #if DEBUG
//        Swift.print(items, separator: separator, terminator: terminator)
//        #endif
//    }
//    // リリースビルドでprint, debugPrintを無効化
//    func print(object: Any) {
//            Swift.print(object, terminator: "")
//        #endif
//    }
//    func debugPrint(object: Any) {
//        #if DEBUG
//            Swift.debugPrint(object, terminator: "")
//        #endif
//    }
//    // リリースビルドでNSLog無効化
//    func NSLog(message:String){
//        #if DEBUG
//            Foundation.NSLog(message)
//        #endif
//    }
//    func NSLog(format:String, _ args:CVarArg...){
//        #if DEBUG
//            Foundation.NSLog(String(format: format, arguments: args))
//        #endif
//    }
//
    
    // TODO: バックエンドで動かす。https://qiita.com/SatoTakeshiX/items/8e1489560444a63c21e7

    
    /// Bluetoothの状態をNotificationCenterに通知する。
    ///
    /// - Parameter peripheral:CBPeripheralManager
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let center = NotificationCenter.default

        if peripheral.state == CBManagerState.poweredOn {
            NSLog("BLE Power On")
            center.post(name: Settings.BluetoothNotification,
                        object: true)
        }else{
            NSLog("BLE Power Off")
            center.post(name: Settings.BluetoothNotification,
                        object: false)
        }
    }
    

    var window: UIWindow?

//    var backgroundTaskID : UIBackgroundTaskIdentifier = 0
    var tbRangingTaskID : UIBackgroundTaskIdentifier = 0
    var hotspotManagerTaskID : UIBackgroundTaskIdentifier = 0
    var rewordWatchTimerTaskID : UIBackgroundTaskIdentifier = 0

    var rewordTimer:Timer = Timer()
    
    var manager : CBPeripheralManager!
    
    var locationManager:CLLocationManager!
    
    var myLocation:CLLocation!
    
    var lastRequestLocation:CLLocation!
    
    var isInitOkSWAMP:Bool!
    
    var beacons:[TbBTServiceBeaconData] = []
    
//    var logger:PURLogger!

    // 接続可能なWifiリスト
    var wifis: [WifiInfo] = []

    // 周りのWifiリスト
    var otherWifis: [WifiInfo] = []
    
    func getWifiInformation() -> WifiHotSpotData? {
        var hsData:WifiHotSpotData?
        
#if arch(i386) || arch(x86_64)
    return nil
//    hsData = WifiHotSpotData(ssid: "root246", bssId: "xxxxxx")
    hsData = WifiHotSpotData(ssid: "testroot246", bssId: "xxxxxx")
            return hsData
#else
        if #available(iOS 9.0, *) {
            if let information = NEHotspotHelper.supportedNetworkInterfaces() {
//                if information.count == 0 {
//                    return nil
//                }
                for interface in information as! [NEHotspotNetwork] {
                    if interface.ssid == "" {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        return nil
                    }
                    hsData = WifiHotSpotData(ssid: interface.ssid, bssId: interface.bssid, secure: interface.isSecure, autoJoined: interface.didAutoJoin, signalStrength: interface.signalStrength)
                    
//                    NSLog("バッジ3[\(interface.signalStrength * 100)]:\(Int(interface.signalStrength * 100))")
                    UIApplication.shared.applicationIconBadgeNumber = Int(interface.signalStrength * 100)
                    
                    return hsData
//                                return informationDictionary
                }
            }
        } else {
            // Fallback on earlier versions
            let informationArray:NSArray? = CNCopySupportedInterfaces()
            if let information = informationArray {
                let dict:NSDictionary? = CNCopyCurrentNetworkInfo(information[0] as! CFString)
                if let temp = dict {
                    hsData = WifiHotSpotData(ssid: String(describing: temp["SSID"]!), bssId: String(describing: temp["BSSID"]!))
                    return hsData
                }
            }
        }
#endif
        UIApplication.shared.applicationIconBadgeNumber = 0
//        self.connectedWifiData = nil
        return nil
    }

    @objc func reachabilityChanged(notification: NSNotification) {
        NSLog("reachabilityChanged:\(notification)")
        
        let status:NetworkStatus = (self.reachability?.currentReachabilityStatus())!
        
        switch (status) {
        case .NotReachable:  //圏外
            NSLog("圏外");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWWAN:  //3G
            NSLog("3G");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWiFi:  //WiFi
            NSLog("WiFi");
            // バッジを付ける。
            guard let data:WifiHotSpotData = self.getWifiInformation() else {
                break
            }
            NSLog("バッジ1[\(data.signalStrength * 100)]:\(Int(data.signalStrength * 100))")
            UIApplication.shared.applicationIconBadgeNumber = Int(data.signalStrength * 100)

            break;
        }
        
    }
    
    @objc func powerStateChanged(_ notification: Notification) {
        let lowerPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        if lowerPowerEnabled {
            self.debugPush(body: "低電力モードが有効になりました。", identifier: "PowerNotification", level: .level2)
        }else{
            self.debugPush(body: "低電力モードが解除されました。", identifier: "PowerNotification", level: .level2)
        }
    }
    
    var reachability:Reachability?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        NSLog("willFinishLaunchingWithOptions")
        
//        let configuration = PURLoggerConfiguration.default()
//
//        configuration.filterSettings = [
//            PURFilterSetting(filter: ActivityFilter.self, tagPattern: "wilfi.*"),
//            // filter settings ...
//        ]
        
//        PURBufferedOutputSettingsLogLimitKey - バッファリングするログ数(default: 5)
//        PURBufferedOutputSettingsFlushIntervalKey - ログを出力する時間の間隔 (default: 10秒)
//        PURBufferedOutputSettingsMaxRetryCountKey - リトライ回数。この数を超えるとアプリケーションが再起動したりリジュームされるまでリトライしません(default: 3)
        
//        configuration.outputSettings = [
//            PUROutputSetting(output: ConsoleOutput.self,   tagPattern: "wilfi.**"),
//            PUROutputSetting(output: LogServerOutput.self, tagPattern: "wilfi.*",
//                             settings:[PURBufferedOutputSettingsLogLimitKey: 5,
//                                       PURBufferedOutputSettingsFlushIntervalKey: 10,
//                                       PURBufferedOutputSettingsMaxRetryCountKey:3])
//        ]
//
//        self.logger = PURLogger(configuration: configuration)
//        self.logger.post("テストdesu", tag: "wilfi.log")
        
        UNUserNotificationCenter.current().delegate = self
        
        self.reachability = Reachability.forInternetConnection()
        let status:NetworkStatus = (self.reachability?.currentReachabilityStatus())!
        
        switch (status) {
        case .NotReachable:  //圏外
            NSLog("圏外");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWWAN:  //3G
            NSLog("3G");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWiFi:  //WiFi
            NSLog("WiFi");
            // バッジを付ける。
            guard let data:WifiHotSpotData = self.getWifiInformation() else {
                break
            }
            NSLog("バッジ2[\(data.signalStrength * 100)]:\(Int(data.signalStrength * 100))")
            UIApplication.shared.applicationIconBadgeNumber = Int(data.signalStrength * 100)
            break;
        }
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.reachabilityChanged),
                           name: NSNotification.Name(rawValue: "kReachabilityChangedNotification"),
                           object: nil)

        self.reachability?.startNotifier()
        

        // 位置情報更新時にアプリのプロセスが停止している場合もここから起動
        // 位置情報起因で起動した場合
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            self.debugPush(body: "willFinishLaunchingWithOptions(位置情報起因で起動)", identifier: "LaunchingNotification", level: .level3)
            self.startUpLocationManager()
//            locationManager.startMonitoringSignificantLocationChanges()
        }else{
            self.debugPush(body: "willFinishLaunchingWithOptions(ノーマル起動)", identifier: "LaunchingNotification", level: .level3)
        }

        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /// 成功時には UIBackgroundFetchResultNewData を渡して completionHandler を呼ぶ
        
        let rb:Reachability = Reachability.forInternetConnection()
        let status:NetworkStatus = rb.currentReachabilityStatus()
        
        switch (status) {
        case .NotReachable:  //圏外
            NSLog("圏外");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWWAN:  //3G
            NSLog("3G");
            UIApplication.shared.applicationIconBadgeNumber = 0
            break;
        case .ReachableViaWiFi:  //WiFi
            NSLog("WiFi");
            // バッジを付ける。
            guard let data:WifiHotSpotData = self.getWifiInformation() else {
                break
            }
            NSLog("バッジ2[\(data.signalStrength * 100)]:\(Int(data.signalStrength * 100))")
            UIApplication.shared.applicationIconBadgeNumber = Int(data.signalStrength * 100)
            break;
        }
        
        // TODO: ここは意味がないのかな？
        self.startUpLocationManager()
        
        completionHandler(UIBackgroundFetchResult.newData);
        
        self.debugPush(body: "バックグランドフェッチ実行", identifier: "BackGroundFetchNotification", level: .level3)
    }
    
    @objc func batteryLevelDidChange(notification: NSNotification) {
        NSLog("batteryLevelDidChange")
        // バッテリーの残量を取得する
        let batteryLevel:Float = UIDevice.current.batteryLevel
        
        self.debugPush(body: String(format: "バッテリーの残量:%f%%",(batteryLevel * 100)), identifier: "PowerNotification", level: .level3)
    }
    
    @objc func batteryStateDidChange(notification: NSNotification) {
        NSLog("batteryStateDidChange")
        // バッテリーの充電状態を取得する
        var state:String = ""
        switch UIDevice.current.batteryState {
        case .full:
            state = "full"
            break
        case .unplugged:
            state = "unplugged"
            break
        case .charging:
            state = "charging"
            break
        case .unknown:
            state = "unknown"
            break
        }
        self.debugPush(body: String(format: "バッテリーの充電状態:%@",state), identifier: "PowerNotification", level: .level3)
    }

//    let pedometer = CMPedometer()
//
//    func startStepCounting() {
//        // CMPedometerが利用できるか確認
//        if CMPedometer.isStepCountingAvailable() {
//            NSLog("startStepCounting")
//            // 計測開始
//            pedometer.startUpdates(from: NSDate() as Date, withHandler: {
//                [unowned self] data, error in
//                DispatchQueue.main.async {
//                    print("update")
//                    if error != nil {
//                        // エラー
//                        print("エラー : \(String(describing: error))")
//                    } else {
//                        let lengthFormatter = LengthFormatter()
//                        // 歩数
//                        let steps = data?.numberOfSteps
//                        // 距離
//                        let distance = data?.distance?.doubleValue
//                        // 速さ
////                        let time = data?.endDate.timeIntervalSince((data?.startDate)!)
////                        let time = data?.endDate.timeIntervalSinceDate(data.startDate)
////                        let speed = distance/time
//                        // 上った回数
//                        let floorsAscended = data?.floorsAscended
//                        // 降りた回数
//                        let floorsDescended = data?.floorsDescended
//                        // 結果をラベルに出力
//                        self.debugPush(value: "Steps: \(String(describing: steps))"
//                            + "\n\nDistance : \(lengthFormatter.string(fromMeters: distance!))"
////                            + "\n\nSpeed : \(lengthFormatter.stringFromMeters(speed)) / s"
//                            + "\n\nfloorsAscended : \(String(describing: floorsAscended))"
//                            + "\n\nfloorsDescended : \(String(describing: floorsDescended))"
//                        )
//                    }
//                }
//            })
//        }
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if object == UserDefaults.standard {
//        }else{
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
        
        guard let keyPath1 = keyPath, let change1 = change else {
            return
        }
        
        switch keyPath1 {
        case "sbAppIcon":
            let kind = change1[NSKeyValueChangeKey.kindKey]
            let new = change1[NSKeyValueChangeKey.newKey]
            let old = change1[NSKeyValueChangeKey.oldKey]
            
//            print("kind:\(kind)")
//            print("new:\(new)")
//            print("old:\(old)")
            if new as? Int != old as? Int {
//            if let new = new as? Int, let old = old as? Int, new != old {
//                NSLog(String(format: "変更あり %@ -> %@", old,new))
                NSLog("アイコン変更あり")
                // TODO: ここで次回起動ORフォアグランド時にアイコンを変更するフラグを立てる。
                UserDefaults.standard.set(true, forKey: "sbAppIconUpdate")
                UserDefaults.standard.synchronize()
                
//                print(kind)
            }
        case "sbMapApp":
            let kind = change1[NSKeyValueChangeKey.kindKey]
            let new = change1[NSKeyValueChangeKey.newKey]
            let old = change1[NSKeyValueChangeKey.oldKey]
            
            //            print("kind:\(kind)")
            //            print("new:\(new)")
            //            print("old:\(old)")
            if new as? Int != old as? Int {
                //            if let new = new as? Int, let old = old as? Int, new != old {
                //                NSLog(String(format: "変更あり %@ -> %@", old,new))
                NSLog("マップ変更あり")
                // TODO: ここで次回起動ORフォアグランド時にアイコンを変更するフラグを立てる。
                UserDefaults.standard.set(true, forKey: "sbMapAppUpdate")
                UserDefaults.standard.synchronize()
                
                //                print(kind)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog("didFinishLaunchingWithOptions:")
        
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: "sbAppIcon",
                                          options: [ .new , .old],
                                          context: nil)

        UserDefaults.standard.addObserver(self,
                                          forKeyPath: "sbMapApp",
                                          options: [ .new , .old],
                                          context: nil)

        // GoogleMapに変更された場合使えるか？チェックする
        if UserDefaults.standard.integer(forKey: "sbMapApp") == 2 {
            if !UIApplication.shared.canOpenURL(URL(string: Settings.GOOGLE_MAP_URL_SCHEME)!) {
                NSLog("GoogleMap使えない")
                UserDefaults.standard.set(1, forKey: "sbMapApp")
                UserDefaults.standard.synchronize()
            }
        }

//        UserDefaults.standard.set(3, forKey: "sbAppIcon")
        
//        http://maps.apple.com/?sll=35.690735,139.699827&q=滞在場所
//        let urlString =  String(format: "http://maps.apple.com/maps?ll=%1.6f,%1.6f&q=%@&z=10&spn=100",35.6615510527695,139.706905384822,"滞在場所".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!)
//        UIApplication.shared.open(NSURL(string: urlString)! as URL, options: [:], completionHandler: nil)

        // ロケーションマネージャの作成.
        self.locationManager = CLLocationManager()
        
        // デリゲートを自身に設定.
        self.locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        // バッテリー
        // バッテリー状態を監視できるようにする
        UIDevice.current.isBatteryMonitoringEnabled = true
        
//        let batteryLevel: Float = UIDevice.current.batteryLevel
        // バッテリー残量監視オン
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.batteryLevelDidChange),
                                                         name: NSNotification.Name.UIDeviceBatteryLevelDidChange,
                                                         object: nil)
        // バッテリー充電状態監視オン
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.batteryStateDidChange),
                                               name: NSNotification.Name.UIDeviceBatteryStateDidChange,
                                               object: nil)

//        self.startStepCounting()
        
        // 低電力モード
        NotificationCenter.default.addObserver(self,
                           selector: #selector(self.powerStateChanged),
                           name : NSNotification.Name.NSProcessInfoPowerStateDidChange,
                           object: nil)

        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        testWifi()

        // TODO: 初回起動（ウォークスルー）のチュートリアルも必要？(EAIntroView) http://last-1.blog.jp/archives/2466607.html
        
        // TODO: デバッグでフォアグランドでもPush通知を表示する。
        UNUserNotificationCenter.current().delegate = self

        // バックランド更新の確認らしい
        let backgroundRefreshStatus:UIBackgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
        switch (backgroundRefreshStatus) {
        case .available:
            NSLog("backgroundRefreshStatus: バックグラウンド更新が可能")
            break
        case .denied:
            NSLog("backgroundRefreshStatus: バックグラウンド更新はユーザによって禁止されている")
            break
        case .restricted:
            NSLog("backgroundRefreshStatus: デバイス設定により無効にされている（ユーザが有効にすることはできない）")
            break
        }
        
//        self.startRewordTimer()

        // ユーザIDの生成と取得
        let userId:String = Settings.sharedManager.getUserID()
            
        UserDefaults.standard.setValue(userId, forKey: "sbUserID")

        //        self.setUpLocationManager()
        
//        self.setUp3bSDK()
        
//        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: "root246")
//        if let wifi = AppDelegate.getWIFIInformation() {
//            print(wifi)
//        }
        
//        if let interfaces:CFArray = CNCopySupportedInterfaces() {
////            let interfaces = CNCopySupportedInterfaces()
//            let count = CFArrayGetCount(interfaces)
//            if count > 0 {
//                print("Count=\(count)")
//                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, 0)
//                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
//                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
//                if unsafeInterfaceData != nil {
//                    let interfaceData = unsafeInterfaceData as Dictionary!
//                    let ssid = interfaceData!["SSID"] as! String
//                    let bssid = interfaceData!["BSSID"] as! String
//                    print(interfaceData)
//                    //                print("SSID=\(ssid) BSSID=\(bssid)")
//
//                }
//            }
//        }
        
        
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(UIColor.rgb(r: 92, g: 101, b: 176, alpha: 1))

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear) // バッグのUIは操作できない
        
        self.manager = CBPeripheralManager(delegate : self, queue : nil)
        
//        // pushつうち
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
//            if error != nil {
//                // エラー時の処理
//            }
//            if granted {
//                // デバイストークンの要求
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            }
//        }
        
//        let settings = UIUserNotificationSettings(
//            forTypes: UInt8(UIUserNotificationType.Badge.rawValue)
//                | UIUserNotificationType.Sound
//                | UIUserNotificationType.Alert,
//            categories: nil)
//        application.registerUserNotificationSettings(settings);
        
        // 通知の許可を取る
//        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil)
//        application.registerUserNotificationSettings(settings)
        
//        isPushNotificationEnable()
        
//        application.applicationIconBadgeNumber = 1
        
        Fabric.with([Crashlytics.self])
        
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.printRetrievedWifiNetwork), userInfo: nil, repeats: true)
        
        
//        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
        Crashlytics.sharedInstance().setUserIdentifier(userId)
//        Crashlytics.sharedInstance().setUserName("Test User")
        
//        let titleColor:UIColor = UIColor(red:CGFloat(100) / 255.0,green:CGFloat(109) / 255.0,blue:CGFloat(280) / 255.0,alpha:1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.navigateionTitleColor()]
        
        // TODO: Alamofireでデータ受信が終わるまで待機する方法
        // https://qiita.com/kazuhirox/items/9ecb25bc238ad2d47ff0
        
        
#if arch(i386) || arch(x86_64)
        if let data = self.getWifiInformation() as WifiHotSpotData! {
            Settings.sharedManager.setUdWifiData(wifi: WifiConnectData(ssid:data.ssid))
            //            self.connectedWifiData = WifiConnectData(ssid:data.ssid)
        }
        self.getWifiSpotList()
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: 35.65873024, longitude: 139.6831021)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.getOtherWifisInLocation(location: location)
//        self.getOtherWifisInLocation(coordinate: coordinate)
#endif
        
        // 位置情報更新時にアプリのプロセスが停止している場合もここから起動
        // 位置情報起因で起動した場合
//        var locateionManagerType:WFLocationManagerType = .ForegroundMode
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            self.debugPush(body: "didFinishLaunchingWithOptions(位置情報起因で起動)", identifier: "LaunchingNotification", level: .level3)

            //            locationManager.startMonitoringSignificantLocationChanges()
//            self.setUpLocationManager()
//            locateionManagerType = .BackgroundMode
            self.startUpLocationManager()
        }else{
            self.debugPush(body: "didFinishLaunchingWithOptions(ノーマル起動)", identifier: "LaunchingNotification", level: .level3)
        }

        #if arch(i386) || arch(x86_64)
        #else
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (ssids) in
                stride(from: 0, to: ssids.count, by: 1).forEach {
                    let ssid:String = ssids[$0]
                    NSLog("構成有りのSSID:\(ssid)")
                }
            }
        #endif

        return true
    }

    // 位置情報から近くのWi-Fi取得
    func getOtherWifisInLocation(location:CLLocation) {
//    func getOtherWifisInLocation(coordinate:CLLocationCoordinate2D) {
        if self.lastRequestLocation != nil {
            // 最後にサーバにリクエストしたロケーションと比較する。
            let d:Double = self.lastRequestLocation.distance(from: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
            if d < self.locationManager.distanceFilter {
                NSLog("移動距離が満たないのでサーバに周辺Wi-Fiとりに行かない。distance:\(d) < distanceFilter:\(self.locationManager.distanceFilter)")
                NotificationCenter.default.post(name: Settings.WifiListNotChangeLocationNotification,
                                                object: nil)

                return
            }
        }
        
//        if self.myLocation != nil && self.myLocation.coordinate.latitude == coordinate.latitude &&
//            self.myLocation.coordinate.longitude == coordinate.longitude {
////            NSLog("移動無し")
//            return
//        }
        // TODO: ここで変化の範囲を見た方がいいな。
        
//        NotificationCenter.default.post(name: Settings.WifiListStartLocationNotification,
//                                        object: nil)

        self.lastRequestLocation = location
        
        Server.getOtherWifisList(
            location: location.coordinate,
            success: {(wifiInfo) in
                NotificationCenter.default.post(name: Settings.WifiListChangeLocationNotification,
                                                object: wifiInfo)
        },error: {() in
            NotificationCenter.default.post(name: Settings.WifiListChangeLocationNotification,
                                            object: nil)
        })
    }
    
    // beaconで検知したWi-Fi取得
    func getWifiSpotList() {
#if arch(i386) || arch(x86_64)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            let beaconIDs:[String] = ["0000014606","0000014610","0000014609"]
            let beaconIDs:[String] = ["0000014606","0000014609"]
            Server.doMultiAsyncGetBeaconSpotDetail(beaconIDs: beaconIDs)
//            Server.getDetail(
//                spotId: 1,
//                success: {(wifiInfo) in
//                    var wifis: [WifiInfo] = []
//                    wifis.append(wifiInfo)
//                    print("AAAA:",wifiInfo.description);
//                    NotificationCenter.default.post(name: Settings.WifiListChangeNotification,
//                                                    object: wifis)
//                    
//            },error: {() in
//            })
        }
#else
    
    var beaconIDs:[String] = []
    self.beacons.forEach { (b) in
        beaconIDs.append(b.keycode)
    }
    Server.doMultiAsyncGetBeaconSpotDetail(beaconIDs: beaconIDs)
#endif
    }
    
    //バックグラウンド遷移移行直前に呼ばれる
    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("applicationWillResignActive.")
        // このブロック内は一定時間内に処理が完了しなかった場合に実行される。
//        self.tbRangingTaskID = application.beginBackgroundTask(){
//            [weak self] in
//            application.endBackgroundTask((self?.tbRangingTaskID)!)
//            self?.tbRangingTaskID = UIBackgroundTaskInvalid
//            self?.debugPush(value: "applicationWillResignActive tbRangingTaskID")
//            NSLog("applicationWillResignActive tbRangingTaskID")
//        }
        self.hotspotManagerTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.hotspotManagerTaskID)!)
            self?.hotspotManagerTaskID = UIBackgroundTaskInvalid
            self?.debugPush(body: "applicationWillResignActive hotspotManagerTaskID", identifier: "BackgroundTaskNotification", level: .level3)
            NSLog("applicationWillResignActive hotspotManagerTaskID")
        }
        self.rewordWatchTimerTaskID = application.beginBackgroundTask(){
            [weak self] in
            application.endBackgroundTask((self?.rewordWatchTimerTaskID)!)
            self?.rewordWatchTimerTaskID = UIBackgroundTaskInvalid
            self?.debugPush(body: "applicationWillResignActive rewordWatchTimerTaskID", identifier: "BackgroundTaskNotification", level: .level3)
            NSLog("applicationWillResignActive rewordWatchTimerTaskID")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSLog("applicationDidEnterBackground.猶予時間:\(UIApplication.shared.backgroundTimeRemaining)秒")
            self.debugPush(body: String(format: "applicationDidEnterBackground.猶予時間:%.0f秒",UIApplication.shared.backgroundTimeRemaining), identifier: "BackgroundTaskNotification", level: .level3)
        }

        //        self.debugPush(value: "applicationDidEnterBackground.猶予時間:\(Int(UIApplication.shared.backgroundTimeRemaining))秒")
//        let status = CLLocationManager.authorizationStatus()
//        if status != .authorizedAlways {
//            print("常に許可ではないので止める。")
//            self.locationManager.stopUpdatingLocation() // 位置情報更新はバックグランドで止めて良いか。
//        }
        
        self.startUpLocationManager()
        
        // TODO: 以下ジオフェンスのテスト（フォアグランドでPush通知を消さないとか。）
        // 設定したい場所の情報を作成
        let coordinate:CLLocationCoordinate2D =  CLLocationCoordinate2DMake(35.6615510527695, 139.706905384822)
        
        // 半径、キー文字列をもとにオブジェクトを生成
        let region:CLCircularRegion = CLCircularRegion(center: coordinate, radius: 10, identifier: "F@N")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        
        
        // サービスの開始
        DispatchQueue.global(qos: .userInteractive).async {
            self.locationManager.startMonitoring(for: region)
            self.locationManager.requestState(for: region)
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["ReginInNotifiction","ReginOutNotifiction"])
        
        if UserDefaults.standard.integer(forKey: "sbDebugPushLevel") >= WFDebugPushLevel.level2.rawValue {
            DispatchQueue.main.async {
                let content = UNMutableNotificationContent()
                content.title = "【上村デスクジオフェンスIN通知】"
                content.subtitle = "テスト" // 新登場！
                content.body = "IN"
                content.sound = UNNotificationSound.default()
                let regionIn:CLCircularRegion = CLCircularRegion(center: coordinate, radius: 10, identifier: "F@N")
                regionIn.notifyOnEntry = true
                regionIn.notifyOnExit = false
                
                let trigger = UNLocationNotificationTrigger(region: regionIn, repeats: true)
                let request = UNNotificationRequest(identifier: "ReginInNotifiction",
                                                    content: content,
                                                    trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        NSLog("InPush:\(String(describing: error?.localizedDescription))")
                    }
                })
                
                
                let content2 = UNMutableNotificationContent()
                content2.title = "【上村デスクジオフェンスOUT通知】"
                content2.subtitle = "テスト" // 新登場！
                content2.body = "OUT"
                content2.sound = UNNotificationSound.default()
                let regionOut:CLCircularRegion = CLCircularRegion(center: coordinate, radius: 10, identifier: "F@N")
                regionOut.notifyOnEntry = false
                regionOut.notifyOnExit = true
                
                let trigger2 = UNLocationNotificationTrigger(region: regionOut, repeats: true)
                let request2 = UNNotificationRequest(identifier: "ReginOutNotifiction",
                                                     content: content2,
                                                     trigger: trigger2)
                UNUserNotificationCenter.current().add(request2, withCompletionHandler: { (error) in
                    if error != nil {
                        NSLog("OutPush:\(String(describing: error?.localizedDescription))")
                    }
                })
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("applicationWillEnterForeground.")
//        self.locationManager.requestLocation() // 一度だけ取得
//        self.locationManager.startUpdatingHeading()
//        let status = CLLocationManager.authorizationStatus()
//        if status != .authorizedAlways {
//            print("常に許可ではないので再開する")
//            self.locationManager.startUpdatingLocation() // 位置情報更新はフォアグランドで再開
//        self.locationManager.startMonitoringSignificantLocationChanges() // 大幅に位置が変更したときのみらしい。電池にも優しい

//        }
//        self.locationManager.stopMonitoringSignificantLocationChanges()
//        self.setUpLocationManager()
//        self.locationManager.startUpdatingLocation()
//        self.startUpLocationManager()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("applicationDidBecomeActive.")
        application.endBackgroundTask(self.tbRangingTaskID)
        application.endBackgroundTask(self.hotspotManagerTaskID)
        application.endBackgroundTask(self.rewordWatchTimerTaskID)
        
        //self.locationManager.stopMonitoringSignificantLocationChanges()

        // まだ認証が得られていない場合は、認証ダイアログを表示
//        DispatchQueue.main.async {
//        let status = CLLocationManager.authorizationStatus()
//        if status == CLAuthorizationStatus.notDetermined {
////            // まだ承認が得られていない場合は、認証ダイアログを表示
////            self.locationManager.requestAlwaysAuthorization()
////            // self.locationManager.requestWhenInUseAuthorization()
//            self.startUpLocationManager()
//        }
//        }
        // セキュリティ認証のステータスを取得
//        let status = CLLocationManager.authorizationStatus()
//        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
        self.stop3bSDK()
            self.startUpLocationManager()
        // TODO: ビーコンも再スタート必要?
        self.start3bSDK()
//        }

        if UserDefaults.standard.bool(forKey: "sbAppIconUpdate") == true {
            
            UserDefaults.standard.removeObject(forKey: "sbAppIconUpdate")
            UserDefaults.standard.synchronize()
            
            UIApplication.shared.setAlternateIconName(String(format:"Icon%d",UserDefaults.standard.integer(forKey: "sbAppIcon")), completionHandler: { (error) in
                if (error != nil) {
                    UIApplication.shared.setAlternateIconName(nil)
                    NSLog("AlternateIconError:\(String(describing: error?.localizedDescription))")
                }
            })
        }
        if UserDefaults.standard.bool(forKey: "sbMapAppUpdate") == true {
            
            UserDefaults.standard.removeObject(forKey: "sbMapAppUpdate")
            UserDefaults.standard.synchronize()
            
            // GoogleMapに変更された場合使えるか？チェックする
            if UserDefaults.standard.integer(forKey: "sbMapApp") == 2 {
                if !UIApplication.shared.canOpenURL(URL(string: Settings.GOOGLE_MAP_URL_SCHEME)!) {
                    NSLog("GoogleMap使えない")
                    UserDefaults.standard.set(1, forKey: "sbMapApp")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        
        // TODO: カウンタリセットしたら行って帰ってを繰り返したら永遠につなげられるか。。。
//        self.rewordTimerCounter = 0
    }

    // 但し、Suspended 状態、もしくはデバイス再起動時には、呼ばれない
//    Foreground 実行中から Terminate
//    →applicationWillResignActive→applicationWillTerminate
//    アプリがバックグラウンドに送られ Background 状態になって Terminate
//    →applicationWillResignActive→applicationDidEnterBackground→applicationWillTerminate
//    アプリがバックグラウンドに送られ、停止状態(Suspended)になって Terminate
//    →applicationWillResignActive→applicationDidEnterBackground
    
    func applicationWillTerminate(_ application: UIApplication) {
        let d:WifiConnectData? = Settings.sharedManager.getUdWifiData()
//        NSLog("applicationWillTerminate.",  (connectedWifiData?.ssid)!)
        NSLog("applicationWillTerminate:\(d?.ssid)")

//        debugPush(value: "applicationWillTerminate:")
        
//        guard let notification:UILocalNotification = UILocalNotification.init() else {
//            print("not notifications")
//            return
//        }
//        notification.timeZone = NSTimeZone.default;
//        //            notification.repeatInterval = 0;
//        notification.alertBody = "アプリを終了したから正常にログが取れないからね！";
//        notification.alertAction = "再起動";
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        UIApplication.shared .scheduleLocalNotification(notification)

//        debugPush(value: "applicationWillTerminate:\( (connectedWifiData?.ssid)!)")
        
        if d != nil {
            self.debugPush(body: String(format: "applicationWillTerminate:%@",(d?.ssid)!), identifier: "TerminateNotification", level: .level3)
        }
        
//        debugPush(value: "applicationWillTerminate:\( (connectedWifiData?.ssid)!)")
        
//        let urlString = "https://watchdog.adcrops.net/wilfi/api/spot/connection_success"
//        var request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
//
//        // set the method(HTTP-GET)
//        request.httpMethod = "GET"
//
//        // use NSURLSessionDataTask
//        var task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//            if (error == nil) {
//
//            } else {
//                print("ERROR:\(error?.localizedDescription)")
//            }
//        })

        let url = URL(string: String(format: "https://watchdog.adcrops.net/wilfi/api/spot/connection_success"))
        let task = URLSession.shared.dataTask(with: url!) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            let httpResponse = response as! HTTPURLResponse
            if error != nil || httpResponse.statusCode != 200 {
                print("ERROR")
                return
            }
            print("SUCCESS")
        }
        task.resume()
        
        // 広告監視タイマーが動いていて
        if self.rewordTimer.isValid {
            NSLog("広告監視タイマー動作中")
            if let connectData = self.getWifiInformation() as WifiHotSpotData! {
                NSLog("広告監視タイマー動作中222")
                self.wifis.forEach({ (wifi) in
                    if connectData.ssid == wifi.ssid {
                        NSLog("広告監視タイマー動作中KILL:\(wifi.ssid)")
                        // TODO: アプリ終了時に以下呼ばれないな。。
                        // 現在接続中のWi-Fiがリストにあれば
                        DispatchQueue.main.async {
                            Server.sendConnectionData(spotId: wifi.spotId, type: wifi.spotType, status: ConnectionSuccessStatus.AdWithdrawal) { (flag) in
                                NSLog("広告閲覧KILLエラー:spotId:\(wifi.spotId), sportType:\(wifi.spotType):\(flag)")
                            }
                        }
                        return
                    }
                })
            }
        }
        
        // ネットワーク設定を削除
        // ただし、applicationWillTerminateはTaskSwithcerなどから終了された場合に呼ばれない。
        // そのため、バックグランド処理を入れておく。（applicationWillResignActiveを参照）
        self.resetConfiguredSSIDs()
    }

    
    @objc func printRetrievedWifiNetwork(tm: Timer) {
        if let interfaces = NEHotspotHelper.supportedNetworkInterfaces() {
            for interface in interfaces as! [NEHotspotNetwork] {
                NSLog("--printRetrievedWifiNetwork - \(interfaces)")
                let ssid = interface.ssid
                let bssid = interface.bssid
                let secure = interface.isSecure
                let autoJoined = interface.didAutoJoin
                let signalStrength = interface.signalStrength

                NSLog("ssid: \(ssid)")
                NSLog("bssid: \(bssid)")
                NSLog("secure: \(secure)")
                NSLog("autoJoined: \(autoJoined)")
                NSLog("signalStrength: \(signalStrength)")
            }
        }

//        if let interfaces:CFArray? = CNCopySupportedInterfaces() {
//            print("--CNCopySupportedInterfaces - \(interfaces)")
//            for i in 0..<CFArrayGetCount(interfaces){
//            }
//        }
        
        let informationArray:NSArray? = CNCopySupportedInterfaces()
        if let information = informationArray {
            NSLog("--CNCopySupportedInterfaces - \(informationArray)")
            let dict:NSDictionary? = CNCopyCurrentNetworkInfo(information[0] as! CFString)
            if let temp = dict {
                print(temp)
            }
        }

        
//

    }
    
    func isPushNotificationEnable() -> Bool {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            // push notification enable
            NSLog("Push有効")
            return true
        }else{
            NSLog("Push無効")
            // push notification disabled
            let application = UIApplication.shared
            let url = NSURL(string:UIApplicationOpenSettingsURLString)!
            UIApplication.shared.openURL(url as URL)
            
            return false
        }
    }
    
    func testWifi() {
        
        
        
//        guard let interfaces:CFArray? = CNCopySupportedInterfaces() else {
//            return
//        }
//        print("interfaces: \(interfaces)")
        
//        for i in 0..<CFArrayGetCount(interfaces) {
//        }

        // TODO: これでWifiにIN／OUTしたときには、呼ばれる。
        // フォアグランド時は、UI更新。バックグランド時は、通知となる？
        // このなかでは、単純にObjectへ追加だけの方がいいのかな？？
        
        let isAvailable = NEHotspotHelper.register(options: nil, queue: DispatchQueue.main ) { (cmd) in
//            var hotspotList = [NEHotspotNetwork]()
            
            NSLog("cmd.commandType:\(cmd)")

            let interfaces = NEHotspotHelper.supportedNetworkInterfaces()
            
//            cmd.createResponse(NEHotspotHelperResult.authenticationRequired)
            
            for interface in interfaces as! [NEHotspotNetwork] {
                NSLog("--- \(interfaces)")
                let ssid = interface.ssid
                let bssid = interface.bssid
                let secure = interface.isSecure
                let autoJoined = interface.didAutoJoin
                let signalStrength = interface.signalStrength
                
                NSLog("ssid: \(ssid)")
                NSLog("bssid: \(bssid)")
                NSLog("secure: \(secure)")
                NSLog("autoJoined: \(autoJoined)")
                NSLog("signalStrength: \(signalStrength)")
            }
            
//            if (cmd.commandType == .evaluate || cmd.commandType == .filterScanList) {
//                if let list = cmd.networkList {
//                    list.forEach { (network) in
//                        print(">", network.ssid, " signal:", network.signalStrength, " bssid:", network.bssid)
////                        if network.SSID == "spw05" {
////                            network.setConfidence(.High)
////                            network.setPassword("password")
////                            hotspotList.append(network)
////                        }
//                    }
////                    let response = cmd.createResponse(.Success)
////                    response.setNetworkList(hotspotList)
////                    response.deliver()
//                } else {
//                    print("list is nil.")
//                }
            
            if cmd.commandType == .evaluate {
                NSLog("evaluate")
                
//                NSLog("isRangingAvailable:\(CLLocationManager.isRangingAvailable())")
//                NSLog("deferredLocationUpdatesAvailable:\(CLLocationManager.deferredLocationUpdatesAvailable())")
//                NSLog("locationServicesEnabled:\(CLLocationManager.locationServicesEnabled())")
//                NSLog("headingAvailable:\(CLLocationManager.headingAvailable())")
//                NSLog("significantLocationChangeMonitoringAvailable:\(CLLocationManager.significantLocationChangeMonitoringAvailable())")
                
                // CLLocationManager.isMonitoringAvailable
                
//                NEHotspotHelperResponse *response = [cmd createResponse:kNEHotspotHelperResultSuccess];
//                [response setNetworkList:hotspotList];
//                [response deliver];

//                let res:NEHotspotHelperResponse = cmd.createResponse(NEHotspotHelperResult.success)
//                res.setNetwork(cmd.network!)
//                res.deliver()
                
                // TODO: 2017/11/21追加してみる。
//                let network = cmd.network!
//                let response = cmd.createResponse(.success)
//                network.setConfidence(.high)
//                response.setNetwork(network)
//                response.deliver()
                
                DispatchQueue.main.async {
                    let content = UNMutableNotificationContent()
                    
//                    // バッジを付ける。
//                    NSLog("バッジ[\((cmd.network?.signalStrength)! * 100)]:\(Int((cmd.network?.signalStrength)! * 100))")
//                    UIApplication.shared.applicationIconBadgeNumber = Int((cmd.network?.signalStrength)! * 100)
                    
                    content.title = "【接続通知】"
                    content.subtitle = "以下のWi-Fiに接続" // 新登場！
//                    print(cmd.network?.ssid)
                    content.body = String(format: "%@に接続しました。", (cmd.network?.ssid)!)
                    content.sound = UNNotificationSound.default()
                    
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
                    let request = UNNotificationRequest(identifier: "ConnectNotifiction",
                                                        content: content,
                                                        trigger: nil)
                    
                    // ローカル通知予約
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

                    //
                }
            }else if cmd.commandType == .logoff {
                NSLog("logoff")
                self.debugPush(body: "logoff", identifier: "NetworkNotification", level: .level3)

                DispatchQueue.main.async {
                    let content = UNMutableNotificationContent()
                    content.title = "【切断通知】"
                    content.subtitle = "以下のWi-Fiから切断" // 新登場！
                    //                    print(cmd.network?.ssid)
                    content.body = String(format: "%@から切断しました。", (cmd.network?.ssid)!)
                    content.sound = UNNotificationSound.default()
                    
                    //                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
                    let request = UNNotificationRequest(identifier: "DisConnectNotifiction",
                                                        content: content,
                                                        trigger: nil)
                    
                    // ローカル通知予約
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }else if cmd.commandType == .authenticate {
                self.debugPush(body: "authenticate", identifier: "NetworkNotification", level: .level3)
            }else if cmd.commandType == .filterScanList {
                if let list = cmd.networkList {
                    list.forEach { (network) in
                        print(">", network.ssid, " signal:", network.signalStrength, " bssid:", network.bssid)
                    }
                }
                self.debugPush(body: "filterScanList", identifier: "NetworkNotification", level: .level3)
            }else if cmd.commandType == .maintain {
                self.debugPush(body: "maintain", identifier: "NetworkNotification", level: .level3)
            }else if cmd.commandType == .presentUI {
                self.debugPush(body: "presentUI", identifier: "NetworkNotification", level: .level3)
            }else {
                NSLog("commandType:\(cmd.commandType)")
            }
            
        }
        NSLog("result:\(isAvailable)")
    }

    func stop3bSDK() {
        NSLog("stop3bSDK")
        let btManager:TbBTManager? = TbBTManager.shared()
//        DispatchQueue.main.async {
            btManager?.stopRangingTbBTStaticBeacons(self.locationManager)
            btManager?.stopMonitoringTbBTInitialRegions(self.locationManager)
//        }
    }
    
    
    func start3bSDK() {
        NSLog("start3bSDK")
        TbBTPreliminary.setUpWithCompletionHandler { (success) in
            if success {
                NSLog("[3B]3b OK")
                self.isInitOkSWAMP = true
                var btManager:TbBTManager? = TbBTManager.shared()
                if btManager == nil {
                    btManager = TbBTManager.initSharedManagerUnderAgreement(true)
                    NSLog("[3B]TbBTManager Agreement")
                }
                btManager?.delegate = self
                
                let regions:[CLBeaconRegion] =  btManager?.initialRegions() as! [CLBeaconRegion]
                NSLog("[3B]regions.count:" , regions.count)
                if( regions.count == 0) {
                    NSLog("[3B][Preparation error....");
                }else{
                    
                }
                
                // 端末のBluetooth使用可否状況をチェックします 決定状態の応答に若干のタイムラグがあるので、デリゲートメソッドを応答します
                btManager?.checkCurrentBluetoothAvailability()
                
                // ビーコン領域検知等に必要な条件（ハードウェアサポート及び位置情報サービス設定系）が満たされているかをチェックするユーティリティメソッド
                if TbBTManager.isBeaconEventConditionMet() == true {
                    NSLog("[3B]isBeaconEventConditionMet OK")
                }else{
                    NSLog("[3B]isBeaconEventConditionMet NG")
                }
                
                // アプリがアクティブな状態のときにビーコン領域検知等に必要な条件が満たされているかをチェックするユーティリティメソッド
                //このAppの使用中のみ許可の時にtrueで、常に許可の時はfalseみたい。
                if TbBTManager.isBeaconEventConditionMetForForegroundOnly() == true {
                    NSLog("[3B]isBeaconEventConditionMetForForegroundOnly OK")
                }else{
                    NSLog("[3B]isBeaconEventConditionMetForForegroundOnly NG")
                }
                
                // ハードウェアサポート状態のみをチェックするユーティリティメソッド
                if TbBTManager.isSupportedBeaconEventByDevice() == true {
                    NSLog("[3B]isSupportedBeaconEventByDevice OK")
                }else{
                    NSLog("[3B]isSupportedBeaconEventByDevice NG")
                }
                
                DispatchQueue.global(qos: .userInteractive).async {
                    if btManager?.startMonitoringTbBTInitialRegions(self.locationManager) == true {
                        if btManager?.startRangingTbBTStaticBeacons(self.locationManager) == true {
                            NSLog("[3B] start OK")
                        }else{
                            //                if btManager?.startMonitoringTbBTInitialRegions(self.locationManager) == true {
                            NSLog("[3B] start NG")
                            //                    NotificationCenter.default.post(name: Settings.WifiListStartNotification,
                            //                                                    object: nil)
                        }
                    }else{
                        NSLog("[3B] start NG")
                    }
                }
            }else{
                NSLog("[3B]3b NG")
                self.isInitOkSWAMP = false
            }
        }
    }
    
//    public enum WFLocationManagerType: Int32 {
//        case ForegroundMode = 0
//        case BackgroundMode = 1
//    }

    func stopLocationManager() {
        if self.locationManager != nil {
            NSLog("ロケーションマネージャを停止")
//            self.locationManager.delegate = nil
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.locationManager.stopMonitoringVisits()
        }
    }
    
    func startUpLocationManager() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
//
//        if CLLocationManager.locationServicesEnabled() == false {
            NSLog("ロケーションマネージャまだ使えない。")
            return
        }
        self.stopLocationManager()
        
        // pushつうち
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
            if error != nil {
                // エラー時の処理
            }
            if granted {
                // デバイストークンの要求
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        let applicationState:UIApplicationState = UIApplication.shared.applicationState
        
//        // ロケーションマネージャの作成.
//        self.locationManager = CLLocationManager()
//
//        // デリゲートを自身に設定.
//        self.locationManager.delegate = self
        
        // セキュリティ認証のステータスを取得
//        let status = CLLocationManager.authorizationStatus()
        
        // 位置情報の更新頻度を設定
        /*
        other その他（デフォルト値）
        automotiveNavigation 自動車ナビゲーション用
        fitness 歩行者
        otherNavigation その他のナビゲーションケース（ボート、電車、飛行機)
        */
        
        self.locationManager.activityType = .fitness

        // 精度の設定
        /*
        kCLLocationAccuracyBestForNavigation ナビゲーションに最適な値
        kCLLocationAccuracyBest 最高精度(iOS,macOSのデフォルト値)
        kCLLocationAccuracyNearestTenMeters 10m
        kCLLocationAccuracyHundredMeters 100m（watchOSのデフォルト値）
        kCLLocationAccuracyKilometer 1Km
        kCLLocationAccuracyThreeKilometers 3Km
        */
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // 取得頻度の設定.(1mごとに位置情報取得)
        // 更新イベントの生成に必要な、水平方向の最小移動距離（メートル単位）を指定
        // このプロパティのデフォルト値はkCLDistanceFilterNone（すべての動きを通知）
        self.locationManager.distanceFilter = 100    // 位置情報取得間隔(m)
        // TODO: debug
//        self.locationManager.distanceFilter = kCLDistanceFilterNone

        if status == CLAuthorizationStatus.authorizedAlways {
            NSLog("位置情報常に許可")
            // バックグラウンドで位置情報を取得(これをtrueにすると青くなる。)
            self.locationManager.allowsBackgroundLocationUpdates = true
        }
        // TODO: これここでいいのかな〜。
//        self.locationManager.allowsBackgroundLocationUpdates = true

        NSLog("allowsBackgroundLocationUpdates:\(self.locationManager.allowsBackgroundLocationUpdates)")
        NSLog("pausesLocationUpdatesAutomatically:\(self.locationManager.pausesLocationUpdatesAutomatically)")
        
        // trueにするとバックグラウンドに入ってから15分でstopするので注意。pauseすると通知は受け取れない。
//        self.locationManager.pausesLocationUpdatesAutomatically = false
        // pausesLocationUpdatesAutomaticallyがtrueに設定されていて、アプリがバックグラウンドにいる時にiOSが自動的にポーズを行なった場合、アプリがフォアグラウンドにくるときしか位置情報取得は再開されません。
        
        
        // まだ認証が得られていない場合は、認証ダイアログを表示
//        if status == CLAuthorizationStatus.notDetermined {
//            // まだ承認が得られていない場合は、認証ダイアログを表示
//            self.locationManager.requestAlwaysAuthorization()
//            // self.locationManager.requestWhenInUseAuthorization()
//            return
//        }
        // 大幅変更位置情報サービス
//         self.locationManager.startMonitoringSignificantLocationChanges()
        
        DispatchQueue.global(qos: .userInteractive).async {
            if applicationState == UIApplicationState.background {
                NSLog("大幅変更位置情報サービス開始")
                self.locationManager.startMonitoringSignificantLocationChanges() // 大幅に位置が変更したときのみらしい。電池にも優しい
            }else{
                NSLog("通常の位置情報サービス開始")
                self.locationManager.startUpdatingLocation() // 位置情報を取得
            }
            
            self.locationManager.startMonitoringVisits()
        }
        //self.locationManager.requestLocation() // 一度だけ取得
    }
    
    // MARK: CLLocationManagerDelegate method
    /*
     (Delegate) 認証のステータスがかわったら呼び出される.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 認証のステータスをログで表示
        var statusStr = "";
        switch (status) {
        case .notDetermined:
            // アプリケーションに関してまだ選択されていない
            //manager.requestAlwaysAuthorization()
            // 3bSDKをstop
            self.stop3bSDK()
            self.stopLocationManager()
            statusStr = "NotDetermined"
            break
        case .restricted:
            // 3bSDKをstop
            self.stop3bSDK()
            self.stopLocationManager()
            statusStr = "Restricted"
            break
        case .denied:
            // 3bSDKをstop
            self.stop3bSDK()
            self.stopLocationManager()
            statusStr = "Denied"
            
            if CLLocationManager.locationServicesEnabled() {
                // 根本の位置情報をOFFっているときは、システムがなんかダイアログ出すので、根本の位置情報がONの時のみに以下を出す。
                let alert: UIAlertController = UIAlertController(title: "位置情報", message: "本アプリを利用するには、設定アプリ→プライバシー→位置情報サービスで位置情報の取得を許可して下さい。" , preferredStyle:  UIAlertControllerStyle.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in
                    UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    
                })
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            
            break
        case .authorizedAlways:
            // 3bSDKをリスタート
            statusStr = "AuthorizedAlways"
            self.startUpLocationManager()
            self.stop3bSDK()
            self.start3bSDK()
            break
        case .authorizedWhenInUse:
            // 3bSDKをリスタート
            statusStr = "AuthorizedWhenInUse"
            self.startUpLocationManager()
            self.stop3bSDK()
            self.start3bSDK()
            break
        }
        
        let center = NotificationCenter.default
        center.post(name: Settings.LocationStatusNotification,
                    object: status)

        NSLog("didChangeAuthorization: \(statusStr)")
        
    }
    
    // 取得に失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // KCLErrorDomain error code = 0はシュミレータで出るらしい。
        NSLog("didFailWithError:\(error.localizedDescription)")
    }
    
    /*
     STEP2(Delegate): LocationManagerがモニタリングを開始したというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        NSLog("didStartMonitoringFor:\(region.identifier)")
        // STEP3: この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // (Delegate didDetermineStateが呼ばれる: STEP4)
//        locationManager.requestState(for: region)
//        manager.requestState(for: region)
    }
    
    /*
     (Delegate) リージョン内に入ったというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion:" ,region)
        if region.identifier == "F@N" {
            debugPush(body: String(format: "[F@N]上村デスクジオフェンス領域%@に入りました",region.identifier), identifier: "BeaconNotification", level: .level2)
            return
        }

        guard let btManager = TbBTManager.shared() else {
            NSLog("btManager error")
            return
        }
        
        if btManager.isInitialRegion(region as! CLBeaconRegion) {
            NSLog("3bのbeacon \(region.identifier)にイン")
            debugPush(body: String(format: "[33]ビーコン領域%@に入りました",region.identifier), identifier: "BeaconNotification", level: .level2)

            // TODO: これいるのかな？
            self.tbRangingTaskID = UIApplication.shared.beginBackgroundTask(){
                [weak self] in
                UIApplication.shared.endBackgroundTask((self?.tbRangingTaskID)!)
                self?.tbRangingTaskID = UIBackgroundTaskInvalid
                NSLog("tbRangingTaskID")
                self?.debugPush(body: "endBackgroundTask tbRangingTaskID", identifier: "BackgroundTaskNotification", level: .level3)

                manager.stopRangingBeacons(in: region as! CLBeaconRegion)
//                manager.stopMonitoring(for: region)
            }

            DispatchQueue.global(qos: .userInteractive).async {
                NSLog("startRangingBeacons")
//                manager.startMonitoring(for: region)
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            }
        }else{
            NSLog("3bのbeaconじゃない")
        }
    }
    
    /*
     (Delegate) リージョンから出たというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("didExitRegion:",region.identifier)
        if region.identifier == "F@N" {
            debugPush(body: String(format: "[F@N]上村デスクジオフェンス領域から%@出ました",region.identifier), identifier: "BeaconNotification", level: .level2)

            manager.stopMonitoring(for: region)
            return
        }

        guard let btManager:TbBTManager = TbBTManager.shared() else {
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
//            manager.stopMonitoring(for: region)
            return
        }
        // サンプル実装：全ての3Bビーコンの電波領域から出たことを通知
        if btManager.isInitialRegion(region as! CLBeaconRegion) {
            NSLog("[3B]ビーコン領域から\(region.identifier)出ました")
            debugPush(body: String(format: "[22]ビーコン領域から%@出ました",region.identifier), identifier: "BeaconNotification", level: .level2)
            NotificationCenter.default.post(name: Settings.WifiListChangeNotification,
                                            object: [])


        }
    }
    
    /*
     STEP4(Delegate): 現在リージョン内にいるかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if region.identifier == "F@N" {
            switch state {
            case .inside:
                NSLog("didDetermineState:\(region.identifier) state:inside")
                break;
            case .outside:
                NSLog("didDetermineState:\(region.identifier) state:outside")
                break;
            case .unknown:
                NSLog("didDetermineState:\(region.identifier) state:unknown")
                break;
            }
            return
        }
        
        switch state {
        case .inside: // リージョン内にいる
            NSLog("locationManager: didDetermineState: CLRegionStateInside:\(region.identifier)")
            // STEP5: すでに入っている場合は、そのままRangingをスタートさせる
            // (Delegate didRangeBeacons: STEP6)
//            manager.startMonitoring(for: region)
            DispatchQueue.global(qos: .userInteractive).async {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
            }
            break;
            
        case .outside:
            NSLog("locationManager: didDetermineState: CLRegionStateOutside:\(region.identifier)")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            NSLog("locationManager: didDetermineState: CLRegionStateUnknown:\(region.identifier)")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        }
    }
    
    /*
     STEP6(Delegate): ビーコンがリージョン内に入り、その中のビーコンをNSArrayで渡される.
     */
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        print("didRangeBeacons:",beacons , " region:" , region)
        if region.identifier == "F@N" {
            self.debugPush(body: "F@N didRangeBeacons", identifier: "BeaconNotification", level: .level3)
            return
        }
        
        guard let btManager:TbBTManager = TbBTManager.shared() else {
            manager.stopRangingBeacons(in: region)
//            manager.stopMonitoring(for: region)
            return
        }
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        
        guard let beaconKeyDatas:[TbBTServiceBeaconData] = btManager.beaconsTrack(beacons, of: region) as? [TbBTServiceBeaconData] else {
            // TODO: self.seaconsをクリアする＆リストを更新？リージョン外に出たことはいいのか。なにもしなくて、Wi−Fi繋がった後にリージョン外に出たらリストから消えちゃうし。
//            if self.removeOutOfRegionsBeacon(beaconKeyDatas: []) {
//                // リストを取得しに行ってテーブルを更新
//                self.getWifiSpotList()
//            }

            // TODO: なんか3BSDKが５回に１回は空を返す？？？ここでの処理は現実的ではない？感じ。
//            print("@@@@@@")
            return
        }
        
        
        
        var isChange:Bool = false

        // データが取得できれば、3Bビーコン領域内
        if (beaconKeyDatas.count > 0) {
            beaconKeyDatas.forEach { (beacon) in
                if self.addFoundBeacon(beacon: beacon) == true {
//                    print(beacon.keycode , "を追加")
                    isChange = true
                }else{
//                    print(beacon.keycode , "は追加済み")
                }
            }
            
//            // TODO: リスト追加済みで領域外に出て接続されてない物を削除する。
//            print("beaconKeyDatas.count:" , beaconKeyDatas.count)
//            if isChange || self.removeOutOfRegionsBeacon(beaconKeyDatas: beaconKeyDatas) {
//                // リストを取得しに行ってテーブルを更新
//                self.getWifiSpotList()
//            }
            // サンプル実装：見つかった一番近めのビーコンのキーコードを取得して通知
//            print("[3B]ビーコン領域\(region.identifier)に入りました[\(beaconKeyDatas.count)]")
//            debugPush(value: "[11]ビーコン領域\(region.identifier)に入りました")
            
//            let firstBeacon:TbBTServiceBeaconData = beaconKeyDatas.first as! TbBTServiceBeaconData
//            print("regionID:\(firstBeacon.regionID) keycode:\(firstBeacon.keycode) segment:\(firstBeacon.segment) switcher:\(firstBeacon.switcher)")
        }

        // リスト追加済みで領域外に出て接続されてない物を削除する。
        if isChange || self.removeOutOfRegionsBeacon(beaconKeyDatas: beaconKeyDatas) {
            // リストを取得しに行ってテーブルを更新
            self.getWifiSpotList()
        }

    }
    
    // wifisに追加済みで領域を出た接続中では無い物を削除する
    func removeOutOfRegionsBeacon(beaconKeyDatas:[TbBTServiceBeaconData]) -> Bool {
        let beforeWifisCount:Int = self.wifis.count
        
//        var chenged:Bool = false
        // 現在接続中のSSID
        let connectedWifi = self.getWifiInformation()
        
        // wifisを軸に、beaconsに存在するか？チェックする。
        var checkedWifis:[WifiInfo] = []
        
        self.wifis.forEach { (info) in
            var check = false
            beaconKeyDatas.forEach({ (beacon) in
                if info.minor == beacon.keycode {
                    check = true
                    return
                }
            })
            
            if check == false {
                if connectedWifi?.ssid == info.ssid {
                    checkedWifis.append(info)
                    return
                }else{
//                    chenged = true
                    // self.beaconsから削除か。
                    var i:Int = 0
                    self.beacons.forEach({ (b) in
                        if b.keycode == info.minor {
                            self.beacons.remove(at: i)
                            NSLog("削除:" , b)
                            return
                        }
                        i = i + 1
                    })
                }
            }else{
                checkedWifis.append(info)
            }
        }
        self.wifis = checkedWifis
        
        NSLog("self.wifis[\(self.wifis.count)] self.beacons[\(self.beacons.count)] beaconKeyDatas[\(beaconKeyDatas.count)]")
        if(beforeWifisCount != self.wifis.count) {
            return true
        }
        return false
    }
    
    // 追加されてないビーコンを入れる。
    // 戻りがtrue入れた。false入れない(既に追加済み)。
    func addFoundBeacon(beacon:TbBTServiceBeaconData) -> Bool {
        var flag:Bool = false
        self.beacons.forEach { (b) in
            if b.keycode == beacon.keycode {
                flag = true
                return
            }
        }
        if flag == true {
            return false
        }
        self.beacons.append(beacon)
        NSLog("regionID:\(beacon.regionID) keycode:\(beacon.keycode) segment:\(beacon.segment) switcher:\(beacon.switcher)")
        NSLog("[3B]ビーコン(\((beacon.keycode)!))を検出しました")
        debugPush(body: String(format: "[3B]ビーコン(%@)を検出しました",(beacon.keycode)!), identifier: "BeaconNotification", level: .level3)
        // TODO: ここでビーコンのKeyでサーバに情報を取りに行ってPushかな？でもPushやると接続する度にいくのか？？
        
        if self.getWifiInformation() != nil {
            NSLog("Wi-Fi接続中")
        }else if self.beacons.count == 1 { // 最初だけ通知（複数個発見した場合に沢山Push通知が飛ぶので）
//        guard let _:WifiHotSpotData = self.getWifiInformation() else {
            DispatchQueue.main.async {
                
                let content = UNMutableNotificationContent()
                content.title = ""
                content.subtitle = ""
                content.body = "近くに接続可能なWi-Fiがあります"
                content.sound = UNNotificationSound.default()
                let request = UNNotificationRequest(identifier: "BeaconFoundNotification",
                                                    content: content,
                                                    trigger: nil)
                // ローカル通知予約
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
//            return true
        }

        return true
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        NSLog("Faield to range:\(error.localizedDescription)");
        locationManager.stopRangingBeacons(in: region)
//        locationManager.stopMonitoring(for: region)
    }
    
    // startUpdatingLocationで呼ばれる。
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // キャッシュしてある位置情報を使うのを避ける
        // 位置情報を取得した時刻で判定
        let age = -locations.first!.timestamp.timeIntervalSinceNow
        
        if age > 15 {
            NSLog("位置情報が古い:\(age)")
            return
        }
        
        //self.getOtherWifisInLocation(coordinate: locations.first!.coordinate)
        self.getOtherWifisInLocation(location: locations.first!)
        
//        NSLog("timestamp:\(locations.first!.timestamp.timeIntervalSinceNow)")
//        NSLog("horizontalAccuracy:\(locations.first!.horizontalAccuracy)")
        
        let applicationState:UIApplicationState = UIApplication.shared.applicationState
        if applicationState == UIApplicationState.background {
            let newLocation:CLLocation = locations.first!
            if self.myLocation != nil {
                let d:Double = self.myLocation.distance(from: CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude))
                debugPush(body: String(format: "[位置情報取得(移動)]緯度:%f 経度:%f [%@m]", newLocation.coordinate.latitude,newLocation.coordinate.longitude ,Int(d).withComma), identifier: "UpdateLocationNotification", level: .level3)
            }else{
                debugPush(body: String(format: "[位置情報取得(初回)]緯度:%f 経度:%f", newLocation.coordinate.latitude,newLocation.coordinate.longitude), identifier: "UpdateLocationNotification", level: .level3)
            }
        }

        self.myLocation = locations.first!
        NSLog("didUpdateLocations:latitude[\(self.myLocation.coordinate.latitude)] longitude[\(self.myLocation.coordinate.longitude)]")
        

        // self.locationManager.stopUpdatingLocation() // 位置情報は一受信して終わりでいいか。(アプリの設定で反映されるからわざわざいいのか。)

    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        NSLog("didVisit")
        let outputFormatter = DateFormatter()
        //ロケールを設定する。
        outputFormatter.locale = NSLocale(localeIdentifier:"ja_JP") as Locale!
        //フォーマットのスタイルを設定する。
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .medium
        
        let arrivalDate = outputFormatter.string(from: visit.arrivalDate)
        let departureDate = outputFormatter.string(from: visit.departureDate)
        
        var type:String = ""
        var identifier:String = ""
        
        if visit.departureDate == NSDate.distantFuture {
            
//        if visit.departureDate.isEqualToDate(NSDate.distantFuture()) {
            // 到着時のメソッド
            type = "到着?"
            identifier = "VisitNotifictionArrival"
        } else if visit.arrivalDate == NSDate.distantPast {
            // その場から離れた時のメソッド
            type = "出発?"
            identifier = "VisitNotifictionDeparture"
        } else {
            type = "滞在?"
            identifier = "VisitNotifiction"
        }
        
//        CLVisitでは到着日時が正しく取れない場合は 0001-01-01 01:00:00 (月日や日時が異なる値になる場合もある)となり、出発日時が正しく取れない場合は 4001-01-01 01:00:00 (同じく、月日や日時が異なる値になる場合もある)となる。
        
        // departureDateは以下を返すときがあるらしい
//        distantFuture
//        Foundation NSDate 10.0- iOS2.0 +
//        めちゃくちゃ遠い未来の日付を返します
        
        // arrivalDateは以下を返すときがあるらしい
//        distantPast
//        Foundation NSDate 10.0- iOS2.0 -
//        めちゃくちゃ遠い過去の日付けを返します
        
//        if visit.departureDate.isEqualToDate(NSDate.distantFuture() as! NSDate) {
//            // A visit has begun, but not yet ended. User must still be at the place.
            // 訪問は始まったが、まだ終了していない。ユーザーはまだその場所にいなければなりません。
//        } else {
//            // The visit is complete, user has left the place.
            // 訪問は完了し、ユーザーはその場所を出ました。
//        }
        
        let message = String(format: "[%@]緯度: %f\n経度: %f\n到着時間: %@\n出発時間: %@", type,visit.coordinate.latitude,visit.coordinate.longitude,arrivalDate,departureDate)

        DispatchQueue.main.async {
            
            let content = UNMutableNotificationContent()
            
            content.title = "【滞在通知】"
            content.subtitle = "CLVisitとやらで滞在時間検知を試す。※タップでMap開きます" // 新登場！
            content.body = message
            content.sound = UNNotificationSound.default()
            content.userInfo = ["latitude": visit.coordinate.latitude,
                                "longitude": visit.coordinate.longitude]
            
//            var image = URL(string: "https://www.google.co.jp/maps/@35.6615510527695,139.706905384822,19z")
//
//            let attachment = try? UNNotificationAttachment(identifier: "com.wilfi.attachment", url: image!, options: nil)
//            if let attachment = attachment {
//                content.attachments = [attachment]
//            }
            
//            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"com.hikaruapp.testNotifer"
//                URL:urlImage
//                options:nil
//                error:nil];
//            content.attachments = @[attachment];

            
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: nil)
            // ローカル通知予約
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    
    // MARK: - TbBTManagerDelegate Methods.
    // [Bluetooth使用可否状態のチェック結果]
    func didDetermineBlutoothAvailability(_ available: Bool) {
        NSLog("[3B]didDetermineBlutoothAvailability:\(available)")
    }
    
    //[領域処理結果系]
    func didPrepareToRefreshRegions(with resultType: TbBTPrepareResultType) {
        NSLog("[3B]didPrepareToRefreshRegions:\(resultType)")
    }
    
    func didFailToPrepareLatestRegionsWithError(_ error: Error!) {
        NSLog("[3B]didFailToPrepareLatestRegionsWithError:\(error)")
    }
    
    //[テストログ送信系]
    func didSendTestLogRequestSuccessfully() {
        NSLog("[3B]didSendTestLogRequestSuccessfully")
    }
    
    func didFailToSendTestLogRequestWithError(_ error: Error!) {
        NSLog("[3B]didFailToSendTestLogRequestWithError:\(error)")
    }
    
    // Notiferをタッチした時呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            let notification = response.notification
            
            // タッチした時の処理
            NSLog("Touch Notifer:\(notification.request.identifier)");
            
            if notification.request.identifier == "VisitNotifiction" ||
                notification.request.identifier == "VisitNotifictionDeparture" ||
                notification.request.identifier == "VisitNotifictionArrival" {
                let userInfo = notification.request.content.userInfo
                NSLog("latitude: \(userInfo["latitude"]!)")
                NSLog("longitude: \(userInfo["longitude"]!)")
                
                let urlString =  String(format: "http://maps.apple.com/maps?ll=%1.6f,%1.6f&q=%@&z=10&spn=100",userInfo["latitude"] as! Double,userInfo["longitude"] as! Double,"滞在していた場所".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!)
                UIApplication.shared.open(NSURL(string: urlString)! as URL, options: [:], completionHandler: nil)
            }
        }
        
        // 終了
        completionHandler();
    }
    
    var rewordTimerCounter:Int = 0
    
//    var rewordMaxTime:Int = 40
    
    // 1.動画途中で、バックグランドで放置
    // 2.動画途中で、タスクからKill
    // 3.Nend広告のロードが失敗した場合は？
    
    // 切断タイマーを開始する。
    func startRewordTimer() {
        NSLog("startRewordTimer")
        if self.rewordTimer.isValid {
            NSLog("startRewordTimer invalidate")
            self.rewordTimer.invalidate()
        }
        self.rewordTimerCounter = 0
        
        self.rewordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatingRewordCounter), userInfo: nil, repeats: true)

    }
    
    // TODO: backgroundTimeRemainingについて
    // このプロパティは、アプリケーションが強制的にシステムによって強制終了される前に、バックグラウンドで実行する必要がある時間を含みます。アプリがフォアグラウンドで実行されている間、このプロパティの値は適切な大きさのままです。アプリがメソッドを使用して1つ以上の長期実行タスクを開始し、バックグラウンドに移行した場合、このプロパティの値は、アプリケーションの実行時間を反映するように調整されます。
    
    @objc func updatingRewordCounter()  {
        self.rewordTimerCounter = self.rewordTimerCounter + 1
        
//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        if UIApplication.shared.applicationState == UIApplicationState.background {
            NSLog(String(format: "猶予時間:%.0f秒",UIApplication.shared.backgroundTimeRemaining))
        }
        
        NSLog("updatingRewordCounter:\(self.rewordTimerCounter)")
        if(self.rewordTimerCounter >= Settings.NEND_REWARD_TIME_LIMIT ) {
            // 時間切れ
            NSLog("時間切れ")
            NotificationCenter.default.post(name: Settings.NendTimeLimitErrorNotification,object: nil)

            self.stopRewordTimer()

            self.resetConfiguredSSIDs()
//            self.connectedWifiData = nil
        }else if self.rewordTimerCounter == (Settings.NEND_REWARD_TIME_LIMIT/2) {
            // 半分過ぎたら警告をPush
            let applicationState:UIApplicationState = UIApplication.shared.applicationState
            if applicationState == UIApplicationState.background {
                DispatchQueue.main.async {
                    let content = UNMutableNotificationContent()
                    content.title = "【警告通知】"
                    content.subtitle = "必ず広告見てね♡"
                    content.body = String(format: "広告を見ないと約%d秒後に自動的に切断されます。", Settings.NEND_REWARD_TIME_LIMIT - self.rewordTimerCounter)
                    content.sound = UNNotificationSound.default()
                    
                    //                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
                    let request = UNNotificationRequest(identifier: "RewardAlertNotifiction",
                                                        content: content,
                                                        trigger: nil)
                    
                    // ローカル通知予約
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }

        }
    }
    
    // 切断タイマーを停止する。
    func stopRewordTimer() {
        NSLog("stopRewordTimer")
        self.rewordTimer.invalidate()
    }
    
    func resetConfiguredSSIDs() {
        NSLog("resetConfiguredSSIDs")
        
#if arch(i386) || arch(x86_64)
#else
    // TODO: 構成は消したら駄目か。全部は。
//        NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (ssids) in
//            stride(from: 0, to: ssids.count, by: 1).forEach {
//                let ssid:String = ssids[$0]
//                NSLog("構成有りのSSID:\(ssid)")
//                NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
//            }
//        }

        let data:WifiConnectData? = Settings.sharedManager.getUdWifiData()
        if data != nil {
            NSLog("現在繋がってるSSID:\((data?.ssid)!)")
            NEHotspotConfigurationManager.shared.removeConfiguration(forSSID:(data?.ssid)!)
        }

#endif
        Settings.sharedManager.resetUdWifiData()

    }
    
    // アプリがフォアグラウンドの時に通知が来たら呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
#if DEBUG
        completionHandler([.alert])
//    completionHandler([.alert, .badge, .sound])
#endif
    }

    func addWifiListOnNFC(wifiInfo:WifiInfo) {
        NSLog("addWifiListOnNFC start")
        // 同じスポットIDがあったら追加しない。(その接続状況をONにする必要はないか。)
        
        var haveFlag = false
        self.wifis.forEach { (info) in
            if info.spotId == wifiInfo.spotId {
                haveFlag = true
//                self.wifis.append(wifiInfo)
//                NSLog("addWifiListOnNFC append")
//                NotificationCenter.default.post(name: Settings.WifiListChangeNotification,
//                                                object: self.wifis)
//
                return
            }
        }
        if haveFlag == false {
            self.wifis.append(wifiInfo)
            NSLog("addWifiListOnNFC append")
        }
        NotificationCenter.default.post(name: Settings.WifiListChangeNotification,
                                        object: self.wifis)
        

        NSLog("addWifiListOnNFC end")

    }
    
    func debugPush(body:String, identifier:String = "NomalNotifiction", level:WFDebugPushLevel = WFDebugPushLevel.level2) {
    
//    func debugPush(value:String) {
        NSLog("【debugPush】:\(body)")
//        if UserDefaults.standard.bool(forKey: "sbDebugPush") == false {
//            return;
//        }
        
        if UserDefaults.standard.integer(forKey: "sbDebugPushLevel") < level.rawValue {
            NSLog("sbDebugPushLevel:\(UserDefaults.standard.integer(forKey: "sbDebugPushLevel"))")
            NSLog("pushLevel:\(level.rawValue)")
            return
        }
        
//        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "【デバッグ通知】"
            let f = DateFormatter()
            f.dateStyle = .long
            f.timeStyle = .medium
            let now = Date()
            content.subtitle = f.string(from: now)
            content.body = body
            content.sound = UNNotificationSound.default()

        //        var image = URL(string: "https://www.google.co.jp/maps/@35.6615510527695,139.706905384822,19z")
//
//        let attachment = try? UNNotificationAttachment(identifier: "com.wilfi.attachment", url: image!, options: nil)
//        if let attachment = attachment {
//            content.attachments = [attachment]
//        }

//        let category = UNNotificationCategory(identifier: "category_select",
//                                              actions: [okAction, ngAction],
//                                              intentIdentifiers: [],
//                                              options: [])

        //                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
            let request = UNNotificationRequest(identifier: String(format: "WFDebug%@",identifier),
                                                content: content,
                                                trigger: nil)
            // ローカル通知予約
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil {
                    NSLog("debugPush:\(String(describing: error?.localizedDescription))")
                }
            })
//        }
    }
}


