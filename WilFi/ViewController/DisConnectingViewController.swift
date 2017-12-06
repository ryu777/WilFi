//
//  DisConnectingViewController.swift
//  WilFi
//
// 切断中View
//
//  Created by Tatsuya Uemura on 2017/10/20.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import NetworkExtension

protocol DisConnectingViewDelegate {
    func finishDicConnected(_ isSuccessful:Bool)
}

class DisConnectingViewController: UIViewController {
    
    @IBOutlet weak var activeIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!

    var wifiData: WifiConnectData?
    
    var disConnectingViewDelegate: DisConnectingViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let visualEffectView = UIVisualEffectView(frame: self.view.frame)
//        visualEffectView.effect = UIBlurEffect(style: .regular)
//        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        self.view.addSubview(visualEffectView)

//        // blur effect view作る styleはdark
        let blurEffect = UIBlurEffect(style:.dark)
        let visualEffectView = UIVisualEffectView(effect:blurEffect)
        visualEffectView.frame = UIScreen.main.bounds//self.view.frame;
//        visualEffectView.frame = self.view.frame;
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
    
    func startDisConnection(wifi:WifiInfo) {
        NSLog("startDisConnection")
        self.infoLabel.text = String(format: "%@から切断しています...",wifi.spotName)

#if arch(i386) || arch(x86_64)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                NSLog("閉じる")
//                appDelegate.connectedWifiData = nil
                appDelegate.resetConfiguredSSIDs()
                self.disConnectingViewDelegate.finishDicConnected(true)
                self.dismiss(animated: false, completion: nil)
            }
        }
#else
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.disConnectingViewDelegate.finishDicConnected(true)
            self.dismiss(animated: false, completion: nil)
            NSLog("閉じる(nil)")
            return
        }
        appDelegate.resetConfiguredSSIDs()

//        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: (appDelegate.connectedWifiData?.ssid)!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSLog("閉じる")
//            appDelegate.connectedWifiData = nil
            self.disConnectingViewDelegate.finishDicConnected(true)
            self.dismiss(animated: false, completion: nil)
        }
#endif
    }
}

