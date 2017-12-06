//
//  WifiTableSectionSeparator.swift
//  WilFi
//
//  Created by Tatsuya Uemura on 2017/11/28.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation

import UIKit

class WifiTableSectionSeparator: UIView {
    
    @IBOutlet weak var line1:UIView!
    @IBOutlet weak var line2:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        line1.layer.masksToBounds = false
        line1.layer.shadowColor = UIColor.white.cgColor
        line1.layer.shadowOpacity = 1.0 // 透明度
        line1.layer.shadowOffset = CGSize(width: 0, height: -0.5) // 距離
        line1.layer.shadowRadius = 0.0 // ぼかし量

        line2.layer.masksToBounds = false
        line2.layer.shadowColor = UIColor.white.cgColor
        line2.layer.shadowOpacity = 1.0 // 透明度
        line2.layer.shadowOffset = CGSize(width: 0, height: -0.5) // 距離
        line2.layer.shadowRadius = 0.0 // ぼかし量
        
        // Initialization code
    }
    
}

