//
//  ViewController.swift
//  WilFi
//
// メインView
//
//  Created by Tatsuya Uemura on 2017/10/13.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import UIKit
import NetworkExtension
import UserNotifications
import SVProgressHUD

import Toast_Swift
import CoreNFC
import MBCircularProgressBar

import MediaPlayer

// TODO: ライブラリ達 https://qiita.com/u651601f/items/08500df9246a6c208241

// TODO: タイマーをCellにいれる。 https://dev.classmethod.jp/smartphone/mbcircularprogressbar/

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,NFCNDEFReaderSessionDelegate,ConnectingViewDelegate,DisConnectingViewDelegate {

    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var headerAlertLabel: UILabel!
//    @IBOutlet weak var headerAlertView: UIView!

//    @IBOutlet weak var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var nfcButton:UIBarButtonItem!
    @IBOutlet weak var settingButton:UIBarButtonItem!

    @IBOutlet weak var progressBar:MBCircularProgressBarView!
    
    let beacon_cell_identifier_comment = "WifiTableViewCell"
    let other_cell_identifier_comment = "WifiTableOtherViewCell"
    let header_cell_identifier_comment = "WifiHeaderTableViewCell"
    let footer_cell_identifier_comment = "WifiFooterTableViewCell"
    let loading_beacon_cell_identifier_comment = "WifiTableLoadingViewCell"
//    let loading_other_cell_identifier_comment = "WifiTableOtherLoadingViewCell"

    var bluetoothState:Bool = false
    
    // 接続可能なWifiリスト
//    var wifis: [WifiInfo] = []
    
    // 周りのWifiリスト
//    var otherWifis: [WifiInfo] = []
    
    // NFC接続のWi-Fi
    var nfcWifi:WifiInfo?
    
    @IBAction func refresh(){
//        if refreshControl.isRefreshing {
//            print("まだ読み込み中...")
//            return
//        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.getWifiSpotList()
//        }

//        self.refreshControl.endRefreshing()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            //        if let url = URL(string:"app-settings:") {
//            if let url = URL(string:"App-Prefs:root=WIFI") {
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }else{
//                    print("開けません。。")
//                }
//            }
//        }
        
    }
    
//    func testWifi() {
//
//
//
//        //        guard let interfaces:CFArray? = CNCopySupportedInterfaces() else {
//        //            return
//        //        }
//        //        print("interfaces: \(interfaces)")
//
//        //        for i in 0..<CFArrayGetCount(interfaces) {
//        //        }
//
//        //  これでWifiにIN／OUTしたときには、呼ばれる。
//        // フォアグランド時は、UI更新。バックグランド時は、通知となる？
//        // このなかでは、単純にObjectへ追加だけの方がいいのかな？？
//
//        let isAvailable = NEHotspotHelper.register(options: nil, queue: DispatchQueue.main ) { (cmd) in
//            //            var hotspotList = [NEHotspotNetwork]()
//
//            print("cmd.commandType:\(cmd)")
//
//            let interfaces = NEHotspotHelper.supportedNetworkInterfaces()
//
//            for interface in interfaces as! [NEHotspotNetwork] {
//                print("--- \(interfaces)")
//                let ssid = interface.ssid
//                let bssid = interface.bssid
//                let secure = interface.isSecure
//                let autoJoined = interface.didAutoJoin
//                let signalStrength = interface.signalStrength
//
//                print("ssid: \(ssid)")
//                print("bssid: \(bssid)")
//                print("secure: \(secure)")
//                print("autoJoined: \(autoJoined)")
//                print("signalStrength: \(signalStrength)")
//            }
//
//            self.refreshControl.endRefreshing()
//            self.wifis.removeAll()
//
//            if (cmd.commandType == .evaluate || cmd.commandType == .filterScanList) {
//                if let list = cmd.networkList {
//                    list.forEach { (network) in
//                        print(">", network.ssid, " signal:", network.signalStrength, " bssid:", network.bssid)
//                        //                        if network.SSID == "spw05" {
//                        //                            network.setConfidence(.High)
//                        //                            network.setPassword("password")
//                        //                            hotspotList.append(network)
//                        //                        }
//
//                        self.wifis.append(WifiData(
//                            spotId:1,
//                            ssid:network.ssid
//                        ))
//
//                    }
//                    self.tableView.reloadData()
//
//                    //ローカル通知
//                    let notification = UILocalNotification()
//                    //ロック中にスライドで〜〜のところの文字
//                    notification.alertAction = "アプリを開く"
//                    //通知の本文
//                    notification.alertBody = "近くのWifi取得のでアプリへ戻るぜよ"
//                    //通知される時間（とりあえず10秒後に設定）
//                    notification.fireDate = NSDate(timeIntervalSinceNow:0) as Date
//                    //通知音
////                    notification.sound = UNNotificationSound.default()
//
////                    notification.soundName = [UNNotificationSound, defaultSound]
//                    //アインコンバッジの数字
////                    notification.applicationIconBadgeNumber = 1
//                    //通知を識別するID
//                    notification.userInfo = ["notifyID":"gohan"]
//                    //通知をスケジューリング
//                    UIApplication.shared.scheduleLocalNotification(notification)
//
//                    //                    let response = cmd.createResponse(.Success)
//                    //                    response.setNetworkList(hotspotList)
//                    //                    response.deliver()
//                } else {
//                    print("list is nil.")
//                }
//            }
//        }
//        print("result:\(isAvailable)")
//    }

    func setBluetoothAndLocationNotification() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.chengeBluetoothState),
                           name: Settings.BluetoothNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(self.chengeLocationState),
                           name: Settings.LocationStatusNotification,
                           object: nil)

        
    }
    @objc func chengeLocationState(notification: NSNotification) {
        NSLog("chengeLocationState:\(notification.object as! CLAuthorizationStatus)")
        var status:CLAuthorizationStatus = notification.object as! CLAuthorizationStatus
        if status != CLAuthorizationStatus.authorizedAlways {
            self.showHeaderView(bluetoothOK: self.bluetoothState, locationOK: false)
        }else{
            self.showHeaderView(bluetoothOK: self.bluetoothState, locationOK: true)
        }
    }
    
    @objc func chengeBluetoothState(notification: NSNotification) {
        NSLog("chengeBluetoothState:\(notification.object as! Bool)")
        
        self.bluetoothState = notification.object as! Bool
//        if state == true {
////            self.headerAlertView.isHidden = true;
//////            self.headerAlertView.frame
//////            self.headerAlertView.hi
//            tableView.tableHeaderView = nil
//
//        }else{
//            // TODO: 2017/11/27 とりあえずコメントアウト
////            self.showHeaderView()
////            self.headerAlertView.isHidden = false;
//        }
        
        let status = CLLocationManager.authorizationStatus()
        if status != CLAuthorizationStatus.authorizedAlways {
            self.showHeaderView(bluetoothOK: self.bluetoothState, locationOK: false)
        }else{
            self.showHeaderView(bluetoothOK: self.bluetoothState, locationOK: true)
        }
            
    }
    
    private func showHeaderView(bluetoothOK:Bool,locationOK:Bool) {
        if bluetoothOK == true && locationOK == true {
            // 非表示
            tableView.tableHeaderView = nil
            return
        }
        
//        if tableView.tableHeaderView == nil {
            print("showHeaderView")
//            // nameには、PostScript名をセット
//            guard let font = UIFont(name: "icomoon", size: 15) else { return }
//            let attributedString = NSAttributedString(string: IconFont.setting.rawValue + " Bluetoothが有効になっていません",
//                                                      attributes: [NSAttributedStringKey.font: font])
            
            let headerCell: WifiHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.header_cell_identifier_comment)! as! WifiHeaderTableViewCell
            let headerView: UIView = headerCell.contentView
//            if tableView.tableHeaderView == nil {
                headerView.frame.size.height = headerCell.setState(bluetoothOK: bluetoothOK, locationOK: locationOK)
                self.tableView.tableHeaderView = headerView
//            }else{
//                UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
//                    headerView.frame.size.height = headerCell.setState(bluetoothOK: bluetoothOK, locationOK: locationOK)
//                    self.tableView.tableHeaderView = headerView
//                }, completion: { (finish) in
//                    
//                })
//            }
//            headerCell.alertLabel.attributedText = attributedString
//            let headerView: UIView = headerCell.contentView
//            tableView.tableHeaderView = headerView
            
//            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
//                let headerView: UIView = headerCell.contentView
////                headerView.frame.size.height = 500
//                self.tableView.tableHeaderView = headerView
//            }, completion: { (finish) in
//
//            })
            
            // 高さの再設定
//            tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: (tableView.tableHeaderView?.frame.size.width)!, height: 200)

            
//        }
    }

    private func showFooterView() {
//        print(tableView.tableFooterView)
        
        //if tableView.tableFooterView == nil {
            print("showFooterView")
        
            let footerCell: WifiFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.footer_cell_identifier_comment)! as! WifiFooterTableViewCell
            let footerView: UIView = footerCell.contentView
            tableView.tableFooterView = footerView
        
//            let v:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
//            v.backgroundColor = UIColor.red
//
//            tableView.tableFooterView = v
        //}
    }

    
//    @objc func alertWatchTest(tm: Timer) {
////        let subviews = self.view.subviews
//        for window in UIApplication.shared.windows {
//            for subview in window.subviews {
////                if subview is UIAlertController {
//                if subview.isKind(of: UIAlertController.self) {
//                    print("Hit:" , subview)
//                }
//                print("No:" , subview)
//            }
//        }
//    }
    

//    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
    
//    @objc func testUpdate() {
        // TODO: バックグラウンド処理の残り時間
//        print(Date(), UIApplication.shared.backgroundTimeRemaining)
//    }
    
    func welcomeToast() {
//        let list:[String] = ["Welcome","メンソーレ","おいでやす","ようこそ",]
        let list:[String] = ["一線は超えていません","ちーがーうーだーろー！","この、ハゲェーー！","記憶にない","ンゴ"]
        
        // 配列の要素の数を調べる
        let number:Int = list.count
        // 配列の要素数を上限とする乱数を生成
        let random:Int = Int(arc4random_uniform(UInt32(number)))
        
        // https://github.com/scalessec/Toast-Swift
        var style = ToastStyle()
        //        style.backgroundColor = UIColor.darkGray
        style.backgroundColor = UIColor.rgb(r: 79, g: 178, b: 227, alpha: 0.8)
//        style.backgroundColor = UIColor.rgb(r: 92, g: 101, b: 176, alpha: 1)
        //        style.verticalPadding = 5.0
        //        style.messageFont = UIFont.systemFont(ofSize: 12.0)
        self.view.makeToast(list[random], duration: 2.0, position: .bottom , style: style)

    }
    
    func changeIcon() {
        // present中はアラートが出ない
//        self.present(UIViewController(), animated: true, completion: {
            UIApplication.shared.setAlternateIconName("Icon1", completionHandler: { (error) in
            })
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad start")

        // 消音らしいがこれやると全体に影響があるな。。
//        let mpVolumeView:MPVolumeView = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//        mpVolumeView.isHidden = true;
//        self.view.addSubview(mpVolumeView)
//
//        for view in mpVolumeView.subviews {
//            if view.isKind(of: UISlider.self) {
//                let volumeSlider:UISlider = view as! UISlider
//                NSLog("ボリュームbefore:\(volumeSlider.value)")
//                volumeSlider.setValue(0.0, animated: false)
//                NSLog("ボリュームafter:\(volumeSlider.value)")
//                break
//            }
//        }
        
//        let audioSession = AVAudioSession.sharedInstance()
//        let volume = audioSession.outputVolume

//        audioSession.setMode(String)
//        NSLog("ボリューム:\(volume)")
//        print(UIApplication.shared.alternateIconName ?? "デフォルトアイコン")
//        UIApplication.shared.setAlternateIconName(nil, completionHandler: nil)
//        UIApplication.shared.setAlternateIconName(nil, completionHandler: { error in print(error) })
        
//        changeIcon()
        
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        let status = CLLocationManager.authorizationStatus()
//        if status == CLAuthorizationStatus.notDetermined {
//            appDelegate?.startUpLocationManager()
//        }

        // TODO: DEBUG時は設定ボタンを表示させておく。
        guard let font = UIFont(name: "icomoon", size: 26) else { return }

#if DEBUG

        self.settingButton.setTitleTextAttributes([NSAttributedStringKey.font: font,NSAttributedStringKey.foregroundColor:UIColor.rgb(r: 79, g: 178, b: 227, alpha: 1)], for: .normal)
        self.settingButton.setTitleTextAttributes([NSAttributedStringKey.font: font,NSAttributedStringKey.foregroundColor:UIColor.rgb(r: 79, g: 178, b: 227, alpha: 1)], for: .highlighted)
        self.settingButton.title = IconFont.setting.rawValue
#else
        self.settingButton.isEnabled = false
        self.settingButton.tintColor = UIColor(white: 0, alpha: 0)
#endif
        
        self.nfcButton.setTitleTextAttributes([NSAttributedStringKey.font: font,NSAttributedStringKey.foregroundColor:UIColor.rgb(r: 79, g: 178, b: 227, alpha: 1)], for: .normal)
        self.nfcButton.setTitleTextAttributes([NSAttributedStringKey.font: font,NSAttributedStringKey.foregroundColor:UIColor.rgb(r: 79, g: 178, b: 227, alpha: 1)], for: .highlighted)
//        let img:UIImage = UIImage.iconFont(icon: .nfc_touch, fontSize: 26.0, rect: CGSize.init(width: 20, height: 20), color: .blue)!
//        self.nfcButton.setBackgroundImage(img, for: UIControlState.normal, barMetrics: UIBarMetrics.default)
        self.nfcButton.title = IconFont.nfc_touch.rawValue

        //        self.settingButton.imageInsets = UIEdgeInsetsMake(100, 0, 0, 0)
        
//        self.settingButton.setTitlePositionAdjustment(UIOffsetMake(0, 2), for: .default)

#if arch(i386) || arch(x86_64)
#else
        if NFCNDEFReaderSession.readingAvailable == false {
            NSLog("NFC使用不可")
            self.nfcButton.isEnabled = false
            self.nfcButton.tintColor = UIColor(white: 0, alpha: 0)
        }
#endif
//        self.nfcButton.imageInsets = UIEdgeInsetsMake(3, 0, 0, 0)

        // TODO: test
//        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
//            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
//        }
//        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(testUpdate), userInfo: nil, repeats: true)

        self.welcomeToast()
//
//        // https://github.com/scalessec/Toast-Swift
//        var style = ToastStyle()
////        style.backgroundColor = UIColor.darkGray
//        style.backgroundColor = UIColor.rgb(r: 92, g: 101, b: 176, alpha: 1)
////        style.verticalPadding = 5.0
////        style.messageFont = UIFont.systemFont(ofSize: 12.0)
//        self.view.makeToast("Welcome WilFi", duration: 2.0, position: .bottom , style: style)
        
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.alertWatchTest), userInfo: nil, repeats: true)

//        testWifi()
        setBluetoothAndLocationNotification()
        
//        let refreshColor = UIColor.rgb(r: 177, g: 182, b: 193, alpha: 1)
//        let attr: [NSAttributedStringKey : Any] = [
//            .foregroundColor : refreshColor
//        ]
//        let attrText = NSAttributedString(string: "Wi-Fi情報を更新", attributes:attr)
        
//        self.refreshControl.attributedTitle = attrText
//        self.refreshControl.tintColor = refreshColor
        
#if arch(i386) || arch(x86_64)
#else
    // リフレッシュは無しでOKかな？
//    self.refreshControl.removeFromSuperview()
    
    //self.refreshControl.isHidden = true
//    self.refreshControl.isEnabled = false
#endif
        // nameには、PostScript名をセット
//        guard let font = UIFont(name: "icomoon", size: 15) else { return }
//        let attributedString = NSAttributedString(string: IconFont.setting.rawValue + " Bluetoothが有効になっていません",
//                                                  attributes: [NSAttributedStringKey.font: font])
//        headerAlertLabel.attributedText = attributedString
        
//        tableView.dataSource = self
//        tableView.delegate = self
        
        let beaconNib:UINib = UINib(nibName: self.beacon_cell_identifier_comment, bundle: nil)
        tableView.register(beaconNib, forCellReuseIdentifier: self.beacon_cell_identifier_comment)

        let otherNib:UINib = UINib(nibName: self.other_cell_identifier_comment, bundle: nil)
        tableView.register(otherNib, forCellReuseIdentifier: self.other_cell_identifier_comment)

        let headerNib:UINib = UINib(nibName: self.header_cell_identifier_comment, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: self.header_cell_identifier_comment)

        let footerNib:UINib = UINib(nibName: self.footer_cell_identifier_comment, bundle: nil)
        tableView.register(footerNib, forCellReuseIdentifier: self.footer_cell_identifier_comment)

        let loadingBeaconNib:UINib = UINib(nibName: self.loading_beacon_cell_identifier_comment, bundle: nil)
        tableView.register(loadingBeaconNib, forCellReuseIdentifier: self.loading_beacon_cell_identifier_comment)
        
//        let loadingOtherNib:UINib = UINib(nibName: self.loading_other_cell_identifier_comment, bundle: nil)
//        tableView.register(loadingOtherNib, forCellReuseIdentifier: self.loading_other_cell_identifier_comment)

//        tableView.tableFooterView = nil
        
//        tableView.refreshControl = self.refreshControl
        
        self.showHeaderView(bluetoothOK: true,locationOK: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showFooterView()
        }
        
//        self.showHeaderView(bluetoothOK: false,locationOK: false)
//        self.showHeaderView(bluetoothOK: false,locationOK: true)
//        self.showHeaderView(bluetoothOK: true,locationOK: false)
//        self.showFooterView()
//        let headerCell: WifiHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.header_cell_identifier_comment)! as! WifiHeaderTableViewCell
//
//        headerCell.alertLabel.attributedText = attributedString
//        let headerView: UIView = headerCell.contentView
//        tableView.tableHeaderView = headerView
        
        
        // TableViewのヘッダーを設定
//        let headerCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: self.header_cell_identifier_comment)!
////        let headerView: UIView = headerCell.contentView
//        tableView.tableHeaderView = headerView
        
        let inval = "welcome-a8net"
        print("inval:\(inval)")

        do {
            print("before1:" , WFEncrypt.getIVbase64String())
            
            let enc = try WFEncrypt.encrypt(value:inval)
            print("before2:" , WFEncrypt.getIVbase64String())
            
            print("enc:\(enc)")
            let dec = try WFEncrypt.decrypt(value: enc);
            print("dec:\(dec!)")
            print("before3:" , WFEncrypt.getIVbase64String())
        }catch let error as WFEncryptError {
            if error == WFEncryptError.EncryptError {
                print("エンコードエラー")
            } else if error == WFEncryptError.DecryptError {
                print("デコードエラー")
            }
        }catch{
            print("謎のエラー")
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        // Wifi一覧取得
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.chengeWifiList),
                           name: Settings.WifiListChangeNotification,
                           object: nil)

        center.addObserver(self,
                           selector: #selector(self.chengeOtherWifiList),
                           name: Settings.WifiListChangeLocationNotification,
                           object: nil)

        center.addObserver(self,
                           selector: #selector(self.notChengeOtherWifiList),
                           name: Settings.WifiListNotChangeLocationNotification,
                           object: nil)

//        center.addObserver(self,
//                           selector: #selector(self.resetWifiList),
//                           name: Settings.WifiListStartNotification,
//                           object: nil)
        
//        center.addObserver(self,
//                           selector: #selector(self.resetOtherWifiList),
//                           name: Settings.WifiListStartLocationNotification,
//                           object: nil)

        center.addObserver(self,
                           selector: #selector(self.finishWifiConnected),
                           name: Settings.WifiConnectedNotification,
                           object: nil)

        // フォアグランド
        center.addObserver(self,
                           selector: #selector(self.viewWillEnterForeground),
                           name: NSNotification.Name.UIApplicationWillEnterForeground,
                           object: nil)
        // バックグラウンド
        center.addObserver(self,
                           selector: #selector(self.viewDidEnterBackground),
                           name: NSNotification.Name.UIApplicationDidEnterBackground,
                           object: nil)
        
        
//        SVProgressHUD.setBackgroundColor(UIColor.clear)
//        SVProgressHUD.setForegroundColor(UIColor.rgb(r: 92, g: 101, b: 176, alpha: 1))
//        SVProgressHUD.show(withStatus: "Wifiを取得中...")
//        SVProgressHUD.show(with: SVProgressHUDMaskType.black)
        
        self.resetWifiList(notification: nil)
        self.resetOtherWifiList(notification: nil)
        
        
        print("viewDidLoad end")

    }

    @objc func viewWillEnterForeground(notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("フォアグラウンド")
            self.tableView.reloadData()
        }
    }
    
    @objc func viewDidEnterBackground(notification: Notification?) {
        if (self.isViewLoaded && (self.view.window != nil)) {
            print("バックグラウンド")
        }
    }
    
    @objc func resetWifiList(notification: NSNotification?) {
        print("resetWifiList")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.wifis.removeAll()
        self.tableView.reloadData()
        guard let cell: WifiTableLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_beacon_cell_identifier_comment, for: IndexPath(row: 0, section: 0)) as? WifiTableLoadingViewCell else{
            return
        }
        cell.infoLabel.text = Settings.WIFI_LIST_START_WORD
    }

    @objc func chengeWifiList(notification: NSNotification) {
        print("chengeWifiList")
        //    func chengeBluetoothState(notification: Notification) {
//        print("chengeWifiList" , notification.object as! [WifiInfo]);
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.wifis.removeAll()
//        // 取得結果が無し
        guard let wifis:[WifiInfo] = notification.object as? [WifiInfo] else {
            self.tableView.reloadData()
            let cell: WifiTableLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_beacon_cell_identifier_comment, for: IndexPath.init(row: 0, section: 1)) as! WifiTableLoadingViewCell
            cell.infoLabel.text = Settings.WIFI_LIST_START_WORD
//            self.refreshControl.endRefreshing()
//            SVProgressHUD.dismiss();
            return
        }

        appDelegate?.wifis = wifis
        self.tableView.reloadData()
//        self.refreshControl.endRefreshing()
//        SVProgressHUD.dismiss();

    }
    
    @objc func resetOtherWifiList(notification: NSNotification?) {
        print("resetOtherWifiList")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.otherWifis.removeAll()
        self.tableView.reloadData()
//        guard let cell: WifiTableOtherLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_other_cell_identifier_comment, for: IndexPath(row: 0, section: 1)) as? WifiTableOtherLoadingViewCell else{
//            return
//        }
//        cell.infoLabel.text = Settings.OTHER_WIFI_LIST_START_WORD
    }

    @objc func chengeOtherWifiList(notification: NSNotification) {
        NSLog("chengeOtherWifiList")
        //        print("chengeWifiList" , notification.object as! [WifiInfo]);
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.otherWifis.removeAll()
        
        // 取得結果が無し
        guard let otherWifis:[WifiInfo] = notification.object as? [WifiInfo] else {
            self.tableView.reloadData()
//            let cell: WifiTableOtherLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_other_cell_identifier_comment, for: IndexPath(row: 0, section: 1)) as! WifiTableOtherLoadingViewCell
//            cell.infoLabel.text = Settings.OTHER_WIFI_LIST_START_WORD
////            self.refreshControl.endRefreshing()
////            SVProgressHUD.dismiss();
            return
        }
        appDelegate?.otherWifis = otherWifis
        self.tableView.reloadData()
//        SVProgressHUD.dismiss();
        
    }

    @objc func notChengeOtherWifiList(notification: NSNotification) {
        NSLog("notChengeOtherWifiList")
        self.tableView.reloadData()
    }

    @objc func finishWifiConnected(notification: NSNotification) {
        //    func chengeBluetoothState(notification: Notification) {
        print("finishWifiConnected" , notification.object as! WifiInfo);
        DispatchQueue.main.async {
            let myViewController = WFAlertViewController(nibName: "WFAlertViewController", bundle: nil)
//            myViewController.setWifiData(wifiInfo: notification.object as! WifiInfo)
            myViewController.modalPresentationStyle = .overCurrentContext
            self.present(myViewController, animated: false, completion: { () -> Void in
                myViewController.setWifiData(wifiInfo: notification.object as! WifiInfo)
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
//        self.navigationItem.title = "WILFI"
//        navigationBar.title = "タイトル変更"
        //ナビゲーションアイテムのタイトルに画像を設定する。
        let title:UIImageView = UIImageView(image:UIImage(named:"logo"))
//        title.contentMode = .scaleAspectFit
//        title.contentMode = .bottom
        self.navigationItem.titleView = title
//        self.navigationItem.titleView = UIImageView(image:UIImage(named:"logo"))
//        print(self.navigationItem.titleView?.frame.size)
        
        self.navigationItem.titleView?.backgroundColor = UIColor.red
        
    }
 
    // ビーコンの一覧には無い周辺のWi-Fiを返却する
    func getOtherWifisNotInBeacon() -> [WifiInfo] {
        var lists:[WifiInfo] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return lists
        }
        // TODO: ここ作成する。
        appDelegate.otherWifis.forEach( { (other) in
            var matchFlag:Bool = false
            appDelegate.wifis.forEach({ (wifi) in
                if other.spotId == wifi.spotId {
                    matchFlag = true
                    return
                }
            })
            if matchFlag == false {
                lists.append(other)
            }
        })
        return lists
    }
    
    // 行数
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if section == 0 {
            if appDelegate?.wifis.count == 0 {
                return 1
            }
            return (appDelegate?.wifis.count)!
        }
//        if appDelegate?.otherWifis.count == 0 {
//            return 1
//        }
        return self.getOtherWifisNotInBeacon().count
//        return (appDelegate?.otherWifis.count)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if indexPath.section == 0 && appDelegate?.wifis.count == 0 {
            let cell: WifiTableLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_beacon_cell_identifier_comment, for: indexPath) as! WifiTableLoadingViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
//        }else if indexPath.section == 1 && appDelegate?.otherWifis.count == 0 {
//            let cell: WifiTableOtherLoadingViewCell = tableView.dequeueReusableCell(withIdentifier: self.loading_other_cell_identifier_comment, for: indexPath) as! WifiTableOtherLoadingViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.none
//            return cell
        }
        
        if indexPath.section == 0 {
            let cell: WifiTableViewCell = tableView.dequeueReusableCell(withIdentifier: self.beacon_cell_identifier_comment, for: indexPath) as! WifiTableViewCell
            
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.parent = self
            cell.tag = indexPath.row
            
            //        let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let wifi:WifiInfo = (appDelegate?.wifis[indexPath.row])!;
            cell.set(wifi: wifi)
            
            //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            //            return cell
            //        }
            
            guard let data = appDelegate?.getWifiInformation() as WifiHotSpotData! else{
//                cell.setWifiSignalStrength(signal: 0)
                cell.setNoConnectedButtonStyle()
                return cell
            }
            //        let appDelegate = UIApplication.shared.delegate as? AppDelegate
            //        if let data = appDelegate?.getWifiInformation() as WifiHotSpotData! {
            //            print("ssid: \(data.ssid) , signalStrength:\(data.signalStrength)")
            if data.ssid == wifi.ssid {
                cell.setWifiSignalStrength(signal: data.signalStrength)
                cell.setConnectedButtonStyle()
            }else{
                cell.setNoConnectedButtonStyle()
//                cell.setWifiSignalStrength(signal: 0)
            }
            //        }else{
            //            cell.setWifiSignalStrength(signal: 0)
            //        }
            //        cell.wifiLabel.text = wifi.ssid
            
            return cell
        }else{
            let cell: WifiTableOtherViewCell = tableView.dequeueReusableCell(withIdentifier: self.other_cell_identifier_comment, for: indexPath) as! WifiTableOtherViewCell
            
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.parent = self
            cell.tag = indexPath.row
            let wifi:WifiInfo = self.getOtherWifisNotInBeacon()[indexPath.row]
//            let wifi:WifiInfo = (appDelegate?.otherWifis[indexPath.row])!
//            print("other wifi:" , wifi.description)
            cell.set(wifi: wifi)
            return cell
        }
    }
    
    // セクション数
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("select.........")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }

    // セクションヘッダーの高さ
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        if section == 0 && appDelegate?.wifis.count == 0 {
//            return 0
//        }else if section == 1 && appDelegate?.otherWifis.count == 0 {
//            return 0
//        }
        if section == 0 {
            return CGFloat.leastNormalMagnitude
//            return CGFloat.leastNormalMagnitude
//            return 0
        }
        let separator:WifiTableSectionSeparator = UINib(nibName: "WifiTableSectionSeparator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! WifiTableSectionSeparator
        return separator.frame.size.height // 30
    }
    
    //この関数内でセクションの設定を行う
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
//        //ヘッダーにするビューを生成
//        let view = UIView()
//        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25)
//        view.backgroundColor = UIColor.rgb(r: 190, g: 195, b: 204, alpha: 1)
//        
//        //ヘッダーに追加するラベルを生成
//        let headerLabel = UILabel()
//        headerLabel.frame =  CGRect(x: 10, y: 0, width: self.view.frame.size.width - 10, height: view.frame.size.height)
//        headerLabel.textColor = UIColor.rgb(r: 239, g: 239, b: 241, alpha: 1)
//        headerLabel.font = UIFont.systemFont(ofSize: 16)
//        headerLabel.textAlignment = NSTextAlignment.left
////        headerLabel.shadowColor = UIColor.black;
//        if(section == 0){
//            headerLabel.text = "接続可能なWi-Fi"
//        } else if (section == 1){
//            headerLabel.text = "周辺のWi-Fi"
//        }
//
//        view.addSubview(headerLabel)
        
//        let vvv = WifiTableSectionSeparator(nibName: "WifiTableSectionSeparator", bundle: nil)
//
//
        
        let separator:WifiTableSectionSeparator = UINib(nibName: "WifiTableSectionSeparator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! WifiTableSectionSeparator
//        NSLog("h:\(separator.frame.size.height)")
        
//        var view2:WifiTableSectionSeparator = WifiTableSectionSeparator(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        return separator
    }
    
    var session: NFCNDEFReaderSession!
    
    /**
     * 設定ボタン
     */
    @IBAction func handleSetting(_ sender: AnyObject) {
//        let application = UIApplication.shared
//        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
//        UIApplication.shared.openURL(url as URL)
        
        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
        UIApplication.shared.open(url as URL, options: [:]) { (bool) in
        }

    }
    
    /**
     * NFCボタン押下時のイベントハンドラ
     */
    @IBAction func handleNFCReaderButton(_ sender: AnyObject) {
        print("handleNFCReaderButton")
        if(self.nfcButton.tag == 0 ) {
            // 接続
#if arch(i386) || arch(x86_64)
        Server.getDetailBySpotID(
            spotId: 4, // 4:UemuraAirMac,5:root246
            success: {(wifi) in
                self.nfcWifi = wifi
                print("DDDD:",self.nfcWifi?.description as Any)
                DispatchQueue.main.async {
                    let myViewController = ConnectingViewController(nibName: "ConnectingViewController", bundle: nil)
                    
                    myViewController.connectingViewDelegate = self
                    
                    myViewController.modalPresentationStyle = .overCurrentContext
                    self.present(myViewController, animated: false, completion: { () -> Void in
                        myViewController.startConnection(wifi: self.nfcWifi!)
                    })
                }
        },error: {() in
            let alert: UIAlertController = UIAlertController(title: "エラー", message: "Wi-Fi情報の取得に失敗しました。" , preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        })
    
#else
        self.session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: true)
//        self.session?.alertMessage = "店舗のWi-Fi接続用のNFCにiPhoneを近づけてください"
        self.session?.alertMessage = "Wi-Fi接続用タグにiPhoneを近づけてください"
        self.session.begin()
    
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.session?.alertMessage = ""
//        }
#endif
        }else{
            // 切断
            let alert: UIAlertController = UIAlertController(title: "Wi-Fiを切断しますか？", message: "切断するには『はい』を\nタップして下さい。" , preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in
                // 遷移するViewを定義.
                let myViewController = DisConnectingViewController(nibName: "DisConnectingViewController", bundle: nil)
                myViewController.disConnectingViewDelegate = self
                
                myViewController.modalPresentationStyle = .overCurrentContext
                
                self.present(myViewController, animated: false, completion: { () -> Void in
                    myViewController.startDisConnection(wifi: self.nfcWifi!)
                })
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK:NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("didDetectNDEFs")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            session.alertMessage = ""
//        }

//        OperationQueue.main.addOperation({
//            session.alertMessage = ""
//            self.session?.alertMessage = ""
//        })
//        Thread.isMainThread
        
        for message in messages {
            for record in message.records {
                if let type = String.init(data: record.type, encoding: .utf8) {
                    print("type: \(type)")
                }
                if let identifier = String.init(data: record.identifier, encoding: .utf8) {
                    print("identifier: \(identifier)")
                }
                if let payload = String.init(data: record.payload, encoding: .utf8) {
                    print("payload: \(payload)")
//                    print(session.accessibilityActivate())
                    
                    // 一応0000014610をチェックしてとかか。
                    let predicate = NSPredicate(format: "SELF MATCHES '\\\\d+'")
                    if !predicate.evaluate(with: payload) {
                        // エラー
                        print("チェックエラー")
//                        session.alertMessage = "読み取りに失敗しました"
//                        self.session?.alertMessage = "読み取りに失敗しました"
                        let alert: UIAlertController = UIAlertController(title: "エラー", message: "読み取りに失敗しました。" , preferredStyle:  UIAlertControllerStyle.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                            (action: UIAlertAction!) -> Void in

                        })
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    // TODO: ここにデータ入ってくるので来たら、ビーコンの情報と接続情報をとって、接続処理
                    
//                    DispatchQueue.main.async {
//                        self.session?.alertMessage = "読み取りに成功しました"
//                        session.alertMessage = "読み取りに成功しました"
//                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + Settings.NFC_FINISH_WAIT_TIME) {
                        Server.getDetailBySpotID(
                            spotId: Int(payload)!, // 4:UemuraAirMac,5:root246
                            success: {(wifi) in
                                self.nfcWifi = wifi
                                print("DDDD:",self.nfcWifi?.description as Any)
                                DispatchQueue.main.async {
                                    let myViewController = ConnectingViewController(nibName: "ConnectingViewController", bundle: nil)
                                    
                                    myViewController.connectingViewDelegate = self
                                    
                                    myViewController.modalPresentationStyle = .overCurrentContext
                                    self.present(myViewController, animated: false, completion: { () -> Void in
                                        myViewController.startConnection(wifi: self.nfcWifi!)
                                    })
                                }
                        },error: {() in
                            let alert: UIAlertController = UIAlertController(title: "エラー", message: "Wi-Fi情報の取得に失敗しました。" , preferredStyle:  UIAlertControllerStyle.alert)
                            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                                (action: UIAlertAction!) -> Void in
                                
                            })
                            alert.addAction(defaultAction)
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            }
        }
        print("end....")
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(#function, error)
        print(error.localizedDescription)
//        DispatchQueue.main.async {
//            session.alertMessage = ""
//            self.session?.alertMessage = ""
//        }

    }
    
    // MARK: ConnectingViewDelegate
    func finishConnected(_ isSuccessful:Bool) {
//        self.nfcButton.image = UIImage(named: "nfc_join")
        self.nfcButton.tag = 1
    }
    
    // MARK: DisConnectingViewDelegate
    func finishDicConnected(_ isSuccessful:Bool) {
//        self.nfcButton.image = UIImage(named: "nfc")
        self.nfcButton.tag = 0
        self.nfcWifi = nil
    }

    
}

