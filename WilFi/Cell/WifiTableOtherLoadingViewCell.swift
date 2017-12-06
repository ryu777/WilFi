//
//  WifiTableViewCell.swift
//  WilFi
//
// Wifiローディング中のCell
//
//  Created by Tatsuya Uemura on 2017/10/19.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit

class WifiTableOtherLoadingViewCell: UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
