//
//  WifiHeaderTableViewCell.swift
//  WilFi
//
// ヘッダーCell
//
//  Created by Tatsuya Uemura on 2017/10/25.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit

class WifiHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var alertLabel: UILabel!

    @IBOutlet weak var bltButton: UIButton!
    
    @IBOutlet weak var locButton: UIButton!

    
    var bltFrame: CGRect!
    var locFrame: CGRect!
    var alertFrame: CGRect!

    var myFrame: CGRect!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let center = NotificationCenter.default
//        center.addObserver(self,
//                           selector: #selector(self.chengeBluetoothState),
//                           name: Settings.BluetoothNotification,
//                           object: nil)
//
        
        guard let font = UIFont(name: "icomoon", size: 13) else { return }
        let bltAttributedString = NSAttributedString(string: IconFont.setting.rawValue + " Bluetoothが有効になっていません",
                                                  attributes: [NSAttributedStringKey.font: font ,
                                                               NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 213, g: 76, b: 73, alpha: 1)])
        bltButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
        bltButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12.5, 0, 0);
        bltButton.setAttributedTitle(bltAttributedString, for: UIControlState.normal)

        let locAttributedString = NSAttributedString(string: IconFont.setting.rawValue + " 位置情報を「常に許可」に設定してください",
                                                  attributes: [NSAttributedStringKey.font: font ,
                                                               NSAttributedStringKey.foregroundColor: UIColor.rgb(r: 213, g: 76, b: 73, alpha: 1)])
        
        locButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
        locButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12.5, 0, 0);
        locButton.setAttributedTitle(locAttributedString, for: UIControlState.normal)
        
        bltFrame = bltButton.frame
        locFrame = locButton.frame
        alertFrame = alertLabel.frame
        myFrame = self.frame
        
        let bltSel = Selector(bltButton, "onBluetoothAlert") {
            NSLog("onBluetoothAlert")
            let url = URL(string:"App-Prefs:root=Bluetooth")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        bltButton.addTarget(self, action: bltSel, for: UIControlEvents.touchUpInside)
        
        let locSel = Selector(bltButton, "onLocationAlert") {
            NSLog("onLocationAlert")
            let url = NSURL(string:UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url as URL, options: [:]) { (bool) in
            }
        }
        locButton.addTarget(self, action: locSel, for: UIControlEvents.touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    // TODO: あ、ViewControllerがselfなのか？
    
//    @objc func reachabilityChanged(notification: NSNotification) {
//        NSLog("1111reachabilityChanged:\(notification)")
//        let url = URL(string:"App-Prefs:root=Bluetooth")
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//    }
    
//    @objc func onBluetoothAlert(_ sender:UIButton) {
//        NSLog("onBtlButton1")
//        let url = URL(string:"App-Prefs:root=Bluetooth")
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//    }
//    
//    @objc func onLocationAlert(_ sender:UIButton) {
//        NSLog("onLocButton1")
//        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
//        UIApplication.shared.open(url as URL, options: [:]) { (bool) in
//        }
//    }

//    @objc func onBluetoothAlert(_ sender:UIButton) {
//        NSLog("onBtlButton1")
//        let url = URL(string:"App-Prefs:root=Bluetooth")
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//    }
    
//    @objc func onLocationAlert(_ sender:UIButton) {
//        NSLog("onLocButton1")
//        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
//        UIApplication.shared.open(url as URL, options: [:]) { (bool) in
//        }
//    }

    // TODO: なぜか繋がらない。。。。
//    @IBAction func onBtlButton(_ sender:UIButton) {
////    }
////
////    @IBAction func onBtlButton(_ sender: Any) {
//        NSLog("onBtlButton")
//        let url = URL(string:"App-Prefs:root=Bluetooth")
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//    }
//
//    @IBAction func onLocButton(_ sender:UIButton) {
////    @IBAction func onLocButton(_ sender: Any) {
//        NSLog("onLocButton")
//        let url = NSURL(string:UIApplicationOpenSettingsURLString)!
//        UIApplication.shared.open(url as URL, options: [:]) { (bool) in
//        }
//    }
//
//    @objc func chengeBluetoothState(notification: NSNotification) {
//        NSLog("chengeBluetoothState:\(notification.object as! Bool)")
//
//        let state:Bool = notification.object as! Bool
//        if state == true {
//        }else{
//        }
//    }

    // 表示を変える。
    func setState(bluetoothOK:Bool , locationOK:Bool) -> CGFloat {
        if bluetoothOK == false && locationOK == false {
            NSLog("両方NG")
            // 両方表示
            self.bltButton.isHidden = false
            self.bltButton.frame = self.bltFrame
            
            self.locButton.isHidden = false
            self.locButton.frame = self.locFrame
            
            self.alertLabel.frame = self.alertFrame
            
            return myFrame.size.height
            
        }else if bluetoothOK == true && locationOK == false{
            NSLog("bluetoothを非表示にして、位置情報と説明ラベルを上げる")
            self.bltButton.isHidden = true
            
            self.locButton.isHidden = false
            self.locButton.frame.origin = CGPoint(x: self.locFrame.origin.x, y: self.locFrame.origin.y - (self.bltFrame.origin.y + self.bltFrame.size.height))
            
            self.alertLabel.frame.origin = CGPoint(x: self.alertLabel.frame.origin.x, y: self.alertLabel.frame.origin.y - (self.bltFrame.origin.y))
            
            return myFrame.size.height - (self.bltFrame.origin.y + self.bltFrame.size.height)
        }else if bluetoothOK == false && locationOK == true {
            NSLog("bluetoothを表示にして、位置情報を非表示にして説明ラベルを上げる")
            self.bltButton.isHidden = false
            self.bltButton.frame.origin = CGPoint(x: self.bltFrame.origin.x, y: self.bltFrame.origin.y + 10)
            
            self.locButton.isHidden = true
            
            self.alertLabel.frame.origin = CGPoint(x: self.alertLabel.frame.origin.x, y: self.alertLabel.frame.origin.y - (self.bltFrame.origin.y))
            return myFrame.size.height - (self.bltFrame.origin.y + self.bltFrame.size.height)
        }else{
            self.bltButton.isHidden = true
            self.locButton.isHidden = true
        }
        return 0
    }
}

