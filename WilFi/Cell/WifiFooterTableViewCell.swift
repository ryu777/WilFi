//
//  WifiFooterTableViewCell.swift
//  WilFi
//
// フッターCell
//
//  Created by Tatsuya Uemura on 2017/10/25.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class WifiFooterTableViewCell: UITableViewCell {
    @IBOutlet weak var faqButton: UIButton!

//    @IBOutlet weak var titleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let maskPath = UIBezierPath(roundedRect: self.bounds,
//                                    byRoundingCorners: [.topLeft, .topRight],
//                                    cornerRadii: CGSize(width: 5.0, height: 5.0))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = maskPath.cgPath
////        self.layer.mask = maskLayer;
//
//        self.titleImage.layer.masksToBounds = true
//        self.titleImage.layer.mask = maskLayer
        
        
        let sel = Selector(faqButton, "onFAQ") {
            NSLog("onFAQ")
            let _url:NSURL = NSURL(string: "https://8crops.com")!
            let _brow = SFSafariViewController(url: _url as URL)
            // バーの色が変わる
//            _brow.preferredBarTintColor = UIColor.rgb(r: 27, g: 116, b: 179, alpha: 1)
            let type = UserDefaults.standard.integer(forKey: "sbAppIcon")
            if type == 1 {
                _brow.preferredBarTintColor = UIColor.rgb(r: 0, g: 55, b: 78, alpha: 1) // デフォルトの背景色
                // バー内のコントロールの色が変わる
                _brow.preferredControlTintColor = UIColor.white
            }else if type == 2 {
                _brow.preferredBarTintColor = UIColor.rgb(r: 172, g: 223, b: 249, alpha: 1) // アイコン2の背景色
                // バー内のコントロールの色が変わる
                _brow.preferredControlTintColor = UIColor.gray
            }else if type == 3 {
                _brow.preferredBarTintColor = UIColor.rgb(r: 247, g: 247, b: 247, alpha: 1) // アイコン3の背景色
                // バー内のコントロールの色が変わる
                _brow.preferredControlTintColor = UIColor.black
            }else{
                _brow.preferredBarTintColor = UIColor.rgb(r: 79, g: 178, b: 227, alpha: 1)
                // バー内のコントロールの色が変わる
                _brow.preferredControlTintColor = UIColor.white
            }
            
            // 左上のボタン
            _brow.dismissButtonStyle = .close
            
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            keyWindow.rootViewController?.present(_brow, animated: true, completion: {
                
            })
        }
        faqButton.addTarget(self, action: sel, for: UIControlEvents.touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: SFSafariViewControllerDelegate
//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        NSLog("safari close")
//    }
}

