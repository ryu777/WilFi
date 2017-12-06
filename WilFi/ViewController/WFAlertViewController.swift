//
//  WFAlertViewController.swift
//  WilFi
//
// 接続後のView（広告表示）
//
//  Created by Tatsuya Uemura on 2017/10/19.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import UserNotifications

import NendAd
import LTMorphingLabel

import AVFoundation

class WFAlertViewController: UIViewController,NADRewardedVideoDelegate {

    @IBOutlet weak var activeIndicatorView: NVActivityIndicatorView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    @IBOutlet weak var messageLabel: LTMorphingLabel!
    
    fileprivate let rewardedVideo = NADRewardedVideo(spotId: Settings.NEND_SPOT_ID, apiKey: Settings.NEND_API_KEY)
    
    private let textList = ["動画広告準備中","動画広告準備中.", "動画広告準備中..", "動画広告準備中..."]
    private var timer: Timer?
    private var index: Int = 0
    private var totalIndex: Int = 0
    private var wifiInfo:WifiInfo?
    
    @objc func updateLabel(timer: Timer) {
        self.messageLabel.text = textList[index]
        
        index += 1
        if index >= textList.count {
            index = 0
        }
        totalIndex += 1
        if(totalIndex > textList.count ) {
            NSLog("[NEND]動画準備:\(self.rewardedVideo.isReady)")
            if self.rewardedVideo.isReady {
                NSLog("[NEND]動画準備完了")
                self.rewardedVideo.showAd(from: self)
                self.timer?.invalidate()
            }else if totalIndex > Settings.NEND_REWARD_TIMEOUT_TIME {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                appDelegate.stopRewordTimer()
                // エラーとする。。
                self.timer?.invalidate()
                self.rewardedVideo.releaseAd()
                self.setErrorParts()
//                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//                    return
//                }
                
                Server.sendConnectionData(spotId: (self.wifiInfo?.spotId)!, type: (self.wifiInfo?.spotType)!, status: ConnectionSuccessStatus.Other) { (flag) in
                    NSLog("Nendが応答不能エラー:spotId:\((self.wifiInfo?.spotId)!), sportType:\((self.wifiInfo?.spotType)!):\(flag)")
                }
                appDelegate.debugPush(body: String(format: "[NEND]%d秒待ちましたが、Nendが応答不能エラー", Settings.NEND_REWARD_TIMEOUT_TIME), identifier: "NendNotification", level: .level1)
            }
        }
    }
    
    @objc func nendLimitError(notification: NSNotification) {
        
        print("nendLimitError")
        
        Server.sendConnectionData(spotId: (self.wifiInfo?.spotId)!, type: (self.wifiInfo?.spotType)!, status: ConnectionSuccessStatus.AdWithdrawal) { (flag) in
            NSLog("広告閲覧エラー:spotId:\((self.wifiInfo?.spotId)!), sportType:\((self.wifiInfo?.spotType)!):\(flag)")
        }
        
        let content = UNMutableNotificationContent()
        content.title = "【残念通知】"
        content.subtitle = "広告閲覧エラー"
        content.body = String(format: "広告ちゃんと見てないから切断したよ(｀へ´)ﾌﾝｯ｡")
        content.sound = UNNotificationSound.default()
        
        let request = UNNotificationRequest(identifier: "NendMovieCancelNotifiction",
                                            content: content,
                                            trigger: nil)
        
        // ローカル通知予約
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        
        self.rewardedVideo.releaseAd()
        NSLog("広告スルーアラート")
        //            self.rewardedVideo.releaseAd()
        // 全ての部品を消しておく。
        self.view.backgroundColor = UIColor.clear
        self.closeButton.isHidden = true
        self.detailLabel.isHidden = true
        self.infoLabel.isHidden = true
        self.activeIndicatorView.isHidden = true
        
        let alert: UIAlertController = UIAlertController(title: "広告閲覧エラー", message: "広告ちゃんと見てないから切断したよ(｀へ´)ﾌﾝｯ｡" , preferredStyle:  UIAlertControllerStyle.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in
            self.dismiss(animated: false, completion: nil)
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad start")
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.nendLimitError),
                           name: Settings.NendTimeLimitErrorNotification,
                           object: nil)

        
        self.messageLabel.morphingEffect = .evaporate
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateLabel(timer:)), userInfo: nil,
                                     repeats: true)
        self.timer?.fire()
        
        //ここの１行を追加
        activeIndicatorView.startAnimating()

        self.closeButton.setTitle(IconFont.close.rawValue, for: UIControlState.normal)

        let blurEffect = UIBlurEffect(style:.dark)
        let visualEffectView = UIVisualEffectView(effect:blurEffect)
        visualEffectView.frame = UIScreen.main.bounds//self.view.frame;
        print(visualEffectView.frame)
//        self.view.addSubview(visualEffectView);
//        self.view.sendSubview(toBack: visualEffectView);
        
        self.detailLabel.text = String(format: "動画広告を最後まで見ることで、接続が継続されます。\n※%d秒以内に最後まで閲覧しなかった場合は、\n自動的に切断されます。",Settings.NEND_REWARD_TIME_LIMIT)
        
        self.closeButton.isHidden = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.startRewordTimer()

        NSLog("viewDidLoad end")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClose(_ sender: Any) {
        NSLog("閉じるボタン")
        self.dismiss(animated: false, completion: nil)
    }
    
    func setWifiData(wifiInfo:WifiInfo) {
        self.wifiInfo = wifiInfo
        self.infoLabel.text = String(format: "%@のWi-Fiに接続しました",wifiInfo.spotName)
        self.rewardedVideo.delegate = self
        // ユーザーIDの設定
        self.rewardedVideo.userId = Settings.sharedManager.getUserID()
        // ログ出力の設定
        self.rewardedVideo.isOutputLog = true
        
        self.rewardedVideo.loadAd()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            if self.rewardedVideo.isReady {
//                print("動画準備完了")
//                self.rewardedVideo.showAd(from: self)
//            }else{
//                print("動画準備不足")
//            }
//        }
    }
    
    func setErrorParts() {
        self.timer?.invalidate()
        self.closeButton.isHidden = false
        self.detailLabel.isHidden = false
        self.detailLabel.text = String(format: "動画広告でエラーが発生しました。\nそのままWi-Fiをご利用下さい(TдT)")
        self.messageLabel.isHidden = true
        self.infoLabel.isHidden = false
        self.activeIndicatorView.stopAnimating()
        self.activeIndicatorView.isHidden = false
    }
    
    
    // MARK: NADRewardedVideoDelegate
    // 1.リワード付与
    func nadRewardVideoAd(_ nadRewardedVideoAd: NADRewardedVideo!, didReward reward: NADReward!)
    {
        NSLog("[NEND] Currency name: \(reward.name!), Currency amount: \(reward.amount)")
    }
    
    // 2.ロード成功
    func nadRewardVideoAdDidReceiveAd(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Receive:\(nadRewardedVideoAd.mediationName as Any)")
        //        self.rewardedVideo.showAd(from: self)
    }
    
    // 3.ロード失敗
    func nadRewardVideoAd(_ nadRewardedVideoAd: NADRewardedVideo!, didFailToLoadWithError error: Error!)
    {
        NSLog("[NEND] Did Fail to Receive. error: \(error.localizedDescription)")
        self.rewardedVideo.releaseAd()
        self.setErrorParts()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.debugPush(body: String(format: "[NEND] Did Fail to Receive. error:%@", error.localizedDescription), identifier: "NendNotification", level: .level1)
    }
    
    // 4.表示失敗
    func nadRewardVideoAdDidFailed(toPlay nadRewardedVideoAd: NADRewardedVideo!) {
        NSLog("[NEND] Did Fail to Show. error")
        self.setErrorParts()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.debugPush(body: String(format: "[NEND] Did Fail to Show. error"), identifier: "NendNotification", level: .level1)
    }
    
    // 5.広告表示
    func nadRewardVideoAdDidOpen(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Open.")
        // ここでスタートすると穴をくぐられる可能性がアル。
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        appDelegate.startRewordTimer()
    }
    
    // 6.動画再生
    func nadRewardVideoAdDidStartPlaying(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Start Playing.")
        
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
//        AVAudioPlayer.
//        for window in UIApplication.shared.windows {
//
//            for subview in window.subviews {
//                print("-------");
//                subview.printSubviews()
////                print(su)
//            }
//        }
    }
    
    // 7.動画停止
    func nadRewardVideoAdDidStopPlaying(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Stop Playing.")
    }
 
    // 8.動画視聴終了（動画再生が最後まで完了）
    func nadRewardVideoAdDidCompletePlaying(_ nadRewardedVideoAd: NADRewardedVideo!) {
        NSLog("[NEND] Did Complete Playing.")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.stopRewordTimer()
        
        // NFCで接続した場合にAppDelegateの配列に追加
        if self.wifiInfo?.spotType == SpotType.NFC {
            appDelegate.addWifiListOnNFC(wifiInfo: self.wifiInfo!)
            
            // TODO: NFCでつなげて、接続したアプリ落とした後の起動の場合にはリストには出てこない。

        }
        Server.sendConnectionData(spotId: (self.wifiInfo?.spotId)!, type: (self.wifiInfo?.spotType)!, status: ConnectionSuccessStatus.Success) { (flag) in
            NSLog("接続成功情報送信:spotId:\((self.wifiInfo?.spotId)!), sportType:\((self.wifiInfo?.spotType)!):\(flag)")
        }

        
        // 全ての部品を消しておく。
        self.view.backgroundColor = UIColor.clear
        self.closeButton.isHidden = true
        self.detailLabel.isHidden = true
        self.infoLabel.isHidden = true
        self.activeIndicatorView.isHidden = true
    }
    
    // 9.広告クローズ
    func nadRewardVideoAdDidClose(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Close.")
        self.dismiss(animated: false, completion: nil)
    }

    // 10.広告クリック
    func nadRewardVideoAdDidClickAd(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Click Ad.")
    }

    // 11.インフォメーションボタンクリック
    func nadRewardVideoAdDidClickInformation(_ nadRewardedVideoAd: NADRewardedVideo!)
    {
        NSLog("[NEND] Did Click Information.")
    }
    
}

