//
//  ConnectingViewController.swift
//  WilFi
//
// 接続中View
//
//  Created by Tatsuya Uemura on 2017/10/20.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import NetworkExtension

protocol ConnectingViewDelegate {
    func finishConnected(_ isSuccessful:Bool)
}

class ConnectingViewController: UIViewController {
    
    @IBOutlet weak var activeIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!

    var wifiInfo: WifiInfo?
    var wifiData: WifiConnectData?

    var connectingViewDelegate: ConnectingViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.printRetrievedWifiNetwork), userInfo: nil, repeats: true)

//        let visualEffectView = UIVisualEffectView(frame: self.view.frame)
//        visualEffectView.effect = UIBlurEffect(style: .regular)
//        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        self.view.addSubview(visualEffectView)

//        // blur effect view作る styleはdark
//        let blurEffect = UIBlurEffect(style:.dark)
        let blurEffect = UIBlurEffect(style:.dark)
        let visualEffectView = UIVisualEffectView(effect:blurEffect)
        visualEffectView.frame = UIScreen.main.bounds//self.view.frame;
        print(visualEffectView.frame)
//
//        // blur効果をかけたいviewを作成
//        let view = UIView(frame:self.view.frame);
//        
//        // blur効果viewのcontentViewにblur効果かけたいviewを追加
//        visualEffectView.contentView.addSubview(view)
//        
        // 表示〜
//        self.view.insertSubview(visualEffectView, at: 0)
//        self.view.addSubview(visualEffectView);
//        self.view.sendSubview(toBack: visualEffectView);
        
//        activeIndicatorView.padding = 1;
        //ここの１行を追加
        activeIndicatorView.startAnimating()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startConnection(wifi:WifiInfo) {
        NSLog("startConnection")
        self.wifiInfo = wifi
        self.infoLabel.text = String(format: "%@に接続しています...",wifi.spotName)
        Server.getConnectionData(
            spotId: (self.wifiInfo?.spotId)!,
            success: {(wifiData) in
                NSLog("BBBB:\(wifiData.description)")
                self.wifiData = wifiData
                self.hotspotConnection()
        },error: {() in
            let alert: UIAlertController = UIAlertController(title: "エラー", message: "Wi-Fi情報の取得に失敗しました。" , preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                self.dismiss(animated: false, completion: nil)
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        })

    }
    
    func hotspotConnection() {
        NSLog("hotspotConnection")
#if arch(i386) || arch(x86_64)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSLog("閉じる")
            // 切断時にSSIDが必要
            Settings.sharedManager.setUdWifiData(wifi: self.wifiData!)
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                appDelegate.connectedWifiData = self.wifiData
//            }
            
//            Settings.sharedManager.setWifi(wifi: self.wifiData!)
//            let d:WifiConnectData? = Settings.sharedManager.getWifi()
//            NSLog((d?.description)!)

            
            NotificationCenter.default.post(name: Settings.WifiConnectedNotification,
                                            object: self.wifiInfo)
            self.connectingViewDelegate.finishConnected(true)
            self.dismiss(animated: false, completion: nil)
        }

#else
        // 設定：isWEB＝true：WEP、false＝WPA/WPA2
        let hotspotConfiguration:NEHotspotConfiguration = NEHotspotConfiguration(ssid: (self.wifiData?.ssid)!, passphrase: (self.wifiData?.passphrase)!, isWEP: (self.wifiData?.isWep)!)
    
        // 接続を一度だけに限定するかどうか。（trueにすると非アクティブに移行後15秒ぐらいで切れてしまうらしい）
        hotspotConfiguration.joinOnce = (self.wifiData?.joinOnce)!
        // 接続設定有効期間日数（明日には忘れるため）
        hotspotConfiguration.lifeTimeInDays = NSNumber.init(value: (self.wifiData?.lifeTime)!)

        // 接続
        NEHotspotConfigurationManager.shared.apply(hotspotConfiguration) { (error) in
            if let _error = error {
                print(_error)
                let e:NSError = _error as NSError
                NSLog("code", e.code)
                
                if e.code == NEHotspotConfigurationError.userDenied.rawValue {
                    // キャンセル
                    NSLog("接続キャンセル")
                    self.dismiss(animated: false, completion: nil)
                    
                }else{
                    let alert: UIAlertController = UIAlertController(title: "エラー", message: _error.localizedDescription , preferredStyle:  UIAlertControllerStyle.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        self.dismiss(animated: false, completion: nil)
                        
                    })
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                NSLog("success.")
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                if let info = appDelegate?.getWifiInformation() {
                    if info.ssid == self.wifiData?.ssid {
                        // 成功
                        // 切断時にSSIDが必要
                        Settings.sharedManager.setUdWifiData(wifi: self.wifiData!)
//                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                            appDelegate.connectedWifiData = self.wifiData
//                        }
                        
                        NotificationCenter.default.post(name: Settings.WifiConnectedNotification,
                                                        object: self.wifiInfo)
                        self.connectingViewDelegate.finishConnected(true)
                        self.dismiss(animated: false, completion: nil)
                    }else{
                        // 失敗
//                        let alert: UIAlertController = UIAlertController(title: "エラー", message: "接続に失敗しました。\nしばらく立ってからお試し下さい" , preferredStyle:  UIAlertControllerStyle.alert)
//                        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
//                            (action: UIAlertAction!) -> Void in
//                            self.dismiss(animated: false, completion: nil)
//                        })
//                        alert.addAction(defaultAction)
//                        self.present(alert, animated: true, completion: nil)
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            }
        }
#endif
    }
    
    // TODO: https://qiita.com/asashin227/items/9fe627609bcfcba023d9
    
    func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
    
//    @objc func printRetrievedWifiNetwork(tm: Timer) {
//        print("printRetrievedWifiNetwork")
////        UIApplication.shared.keyWindow?.subviews
//        for window in UIApplication.shared.windows {
//            for subview in window.subviews {
//                print("-------");
//                subview.printSubviews()
//            }
//        }
    
//        view.printSubviews()
//        if let interfaces = NEHotspotHelper.supportedNetworkInterfaces() {
//            for interface in interfaces as! [NEHotspotNetwork] {
//                print("--printRetrievedWifiNetwork - \(interfaces)")
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
//        }
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // タッチイベントを取得する
//        let touch = touches.first
//        // タップした座標を取得する
//        let tapLocation = touch!.location(in: self.view)
//        print("touchesBegan",tapLocation)
//    }
    
}

