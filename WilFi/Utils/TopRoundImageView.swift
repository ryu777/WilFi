//
//  TopRoundImageView.swift
//  WilFi
//
//  上の角が丸くなるUIImageView
//
//  Created by Tatsuya Uemura on 2017/11/28.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit

class TopRoundImageView: UIImageView {
    var corners: UIRectCorner = [.topLeft, .topRight]
    var radius: CGFloat = 8.0
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        self.corners = corners
        self.radius = radius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: self.corners,
                                    cornerRadii: CGSize(width: self.radius, height: self.radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        
        self.layer.mask = maskLayer
    }
}

