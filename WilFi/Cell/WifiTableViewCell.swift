//
//  WifiTableViewCell.swift
//  WilFi
//
// ビーコンのWifi一覧のCell
//
//  Created by Tatsuya Uemura on 2017/10/19.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class WifiTableViewCell: UITableViewCell,ConnectingViewDelegate,DisConnectingViewDelegate {
    
    var parent:ViewController!
    
    @IBOutlet weak var wifiIconView: TopRoundImageView!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var useCountLabel: UILabel!
    @IBOutlet weak var connectInfoLabel: UILabel!
    @IBOutlet weak var connectTitleLabel: UILabel!
    @IBOutlet weak var wifiStrengthView: UIImageView!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var usersIconView:UIImageView!
    @IBOutlet weak var distanceTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    var isWifiConnected:Bool = false
    
    var wifi:WifiInfo?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.usersIconView.image = UIImage.iconFont(icon: .users, fontSize: 20.0, rect: CGSize.init(width: 15.0, height: 25), color: UIColor.rgb(r: 171, g: 177, b: 223, alpha: 1))!

    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    // FIXME: このしょりはDelegateかな。。
    @IBAction func pushConnecting(_ sender: Any) {
        NSLog("pushConnecting")

        var otherConnected:Bool = false
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let data = appDelegate?.getWifiInformation() as WifiHotSpotData! {
            for i in (0 ..< (appDelegate?.wifis.count)!) {
//            stride(from: 0, to: self.parent.wifis.count, by: 1).forEach {
                let d:WifiInfo = (appDelegate?.wifis[i])!
                if data.ssid == d.ssid {
                    if(self.tag == i) {
                        NSLog("自分は無視");
                    }else{
                        NSLog("i:\(i) その他が接続中");
                        otherConnected = true
                        break
                    }
                }
            }
        }
        
//        for i in (0 ..< self.parent.tableView.numberOfRows(inSection: 0)) {
//            print(i)
//            if(self.tag == i) {
//                print("自分は無視");
////                break
//            }else{
//                if let cell:WifiTableViewCell = self.parent.tableView.cellForRow(at: IndexPath.init(row: i, section: 0)) as? WifiTableViewCell {
//                    if(cell.isWifiConnected) {
//                        print("i:\(i) その他が接続中");
//                        otherConnected = true
//                        break
//                    }else{
//                        print("i:\(i) 未接続");
//                    }
//                }
//            }
//        }
        
//        stride(from: 0, to: self.parent.tableView.numberOfRows(inSection: 0), by: 1).forEach {
//            if(self.tag == $0) {
//                print("ここ接続中");
//            }
//            let cell:WifiTableViewCell = self.parent.tableView.cellForRow(at: IndexPath.init(row: $0, section: 0)) as! WifiTableViewCell
//            if(cell.isWifiConnected) {
//                print("i:\($0) 接続中");
//                otherConnected = true
//            }else{
//                print("i:\($0) 未接続");
//            }
//        }
        
        if(otherConnected) {
            // その他に接続中
            let alert: UIAlertController = UIAlertController(title: "エラー", message: "その他のWi-Fiに接続中です" , preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(defaultAction)
            self.parent.present(alert, animated: true, completion: nil)
            return
        }
        
        if(!isWifiConnected) {
            // 接続する場合
//            let alert: UIAlertController = UIAlertController(title: "Wi-Fiへ接続しますか？", message: "接続するには『はい』を\nタップして下さい。" , preferredStyle:  UIAlertControllerStyle.alert)
//            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in

                // 遷移するViewを定義.
                let myViewController = ConnectingViewController(nibName: "ConnectingViewController", bundle: nil)
                
//                myViewController.modalPresentationStyle = .overCurrentContext
//                myViewController.modalPresentationStyle = .overCurrentContext
                myViewController.connectingViewDelegate = self
                
                myViewController.modalPresentationStyle = .overCurrentContext
//                myViewController.modalTransitionStyle = .crossDissolve
//                myViewController.view.backgroundColor = UIColor.clear
                
                // UIVisualEffectViewを生成する
//                let visualEffectView = UIVisualEffectView(frame: myViewController.view.frame)
//                // エフェクトの種類を設定
//                visualEffectView.effect = UIBlurEffect(style: .regular)
//                // UIVisualEffectViewを他のビューの下に挿入する
//                myViewController.view.insertSubview(visualEffectView, at: 0)

                self.parent.present(myViewController, animated: false, completion: { () -> Void in
                    myViewController.startConnection(wifi: self.wifi!)
                })
        }else{
            // 切断する場合
            let alert: UIAlertController = UIAlertController(title: "Wi-Fiを切断しますか？", message: "切断するには『はい』を\nタップして下さい。" , preferredStyle:  UIAlertControllerStyle.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.destructive, handler:{(action: UIAlertAction!) -> Void in
                // 遷移するViewを定義.
                let myViewController = DisConnectingViewController(nibName: "DisConnectingViewController", bundle: nil)
                myViewController.disConnectingViewDelegate = self

                myViewController.modalPresentationStyle = .overCurrentContext
                
//                self.parent.present(myViewController, animated: false, completion: nil)
                self.parent.present(myViewController, animated: false, completion: { () -> Void in
                    myViewController.startDisConnection(wifi: self.wifi!)
                })
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
                (action: UIAlertAction!) -> Void in
                
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.parent.present(alert, animated: true, completion: nil)
        }
    }
    
    func set(wifi:WifiInfo) {
        self.wifi = wifi
        self.wifiLabel.text = wifi.spotName
        self.detailLabel.text = wifi.detail
        self.useCountLabel.text = wifi.connectionCount.withComma
        self.wifiIconView.af_setImage(withURL: URL(string: wifi.iconUrl)! ,placeholderImage:UIImage(named: "placeholder"))
    }
    
    func finishConnected(_ isSuccessful:Bool) {
        self.setConnectedButtonStyle()
    }
    
    func finishDicConnected(_ isSuccessful:Bool) {
        setNoConnectedButtonStyle()
    }
    
    // TODO: 接続したままでアプリを殺して立ち上げたときどうなる？？「接続中、接続の表示」
    
    // 接続中のボタンの表示
    func setConnectedButtonStyle() {
        self.connectionButton.setTitle("切断する", for: .normal)
        self.connectionButton.setTitle("切断する", for: .highlighted)
        self.connectionButton.backgroundColor = UIColor.rgb(r: 232, g: 233, b: 234, alpha: 1)
        self.connectionButton.tintColor = UIColor.rgb(r: 184, g: 184, b: 184, alpha: 1)
        self.isWifiConnected = true
        self.wifiStrengthView.isHidden = false
        self.useCountLabel.isHidden = true
        self.connectInfoLabel.isHidden = true
        self.connectTitleLabel.isHidden = false
        self.detailLabel.isHidden = true
        self.usersIconView.isHidden = true
        self.distanceTitleLabel.isHidden = true
        self.distanceLabel.isHidden = true
    }

    // 未接続のボタンの表示
    func setNoConnectedButtonStyle() {
        self.connectionButton.setTitle("このWi-Fiに接続する", for: .normal)
        self.connectionButton.setTitle("このWi-Fiに接続する", for: .highlighted)
        self.connectionButton.backgroundColor = UIColor.rgb(r: 27, g: 116, b: 179, alpha: 1)
        self.connectionButton.tintColor = UIColor.rgb(r: 255, g: 255, b: 255, alpha: 1)
        self.isWifiConnected = false
        self.wifiStrengthView.isHidden = true
        self.useCountLabel.isHidden = false
        self.connectInfoLabel.isHidden = false
        self.connectTitleLabel.isHidden = true
        self.detailLabel.isHidden = false
        self.usersIconView.isHidden = false
        self.distanceTitleLabel.isHidden = false
        self.distanceLabel.isHidden = false
    }

    // Wifi強度の設定
    func setWifiSignalStrength(signal:Double) {
        if signal == 0 {
            self.wifiStrengthView.isHidden = true
        }else{
            // range 0.0 (weak/no signal) to 1.0 (strong signal).
            if( signal >= 0.6 ) {
                // バリ３
                self.wifiStrengthView.image = Image.init(named: "wifi3")
            }else if(signal >= 0.3) {
                // ちょい2
                self.wifiStrengthView.image = Image.init(named: "wifi2")
            }else{
                // ジリ貧
                self.wifiStrengthView.image = Image.init(named: "wifi1")
            }
            self.wifiStrengthView.isHidden = false
        }
    }
}
