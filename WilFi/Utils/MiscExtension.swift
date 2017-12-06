//
//  MiscExtension.swift
//  WilFi
//
// Extension
//
//  Created by Tatsuya Uemura on 2017/10/18.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func navigateionTitleColor() -> UIColor {
        return UIColor.rgb(r: 92, g: 101, b: 176, alpha: 1.0)
    }
}

/// カンマ編集制御用NumberFormatter拡張クラス
class DecimalFormatter: NumberFormatter {
    override init() {
        super.init()
        self.locale = Locale(identifier: "ja_JP")
        self.numberStyle = .decimal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension String {
    /// カンマ区切り数字のカンマどり
    var noComma: Int {
        if self.characters.count == 0 {
            return 0
        }
        let decimalFormatter = DecimalFormatter()
        guard let i = decimalFormatter.number(from: self) else {
            preconditionFailure("NumberFormatter.number method failure!")
        }
        return Int(i)
    }
}

extension Int {
    /// カンマ付け
    var withComma: String {
        let decimalFormatter = DecimalFormatter()
        guard let s = decimalFormatter.string(from: self as NSNumber) else {
            fatalError()
        }
        return s
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UITableViewCell {
    
    @IBInspectable
    var selectedBackgroundColor: UIColor? {
        get {
            return selectedBackgroundView?.backgroundColor
        }
        set(color) {
            let background = UIView()
            background.backgroundColor = color
            selectedBackgroundView = background
        }
    }
    
}

//extension CALayer {
//    
//    func setBorderIBColor(color: UIColor!) -> Void{
//        self.borderColor = color.cgColor
//    }
//}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
}

extension UIView {
    
    private var viewInfo: String {
        return "\(classForCoder), frame: \(frame))"
    }
    
    private func subviews(parentView: UIView, level: Int = 0, printSubviews: Bool = false) -> [UIView] {
        var result = [UIView]()
        if level == 0 && printSubviews {
            result.append(parentView)
            NSLog("\(parentView.viewInfo)")
        }
        
        for subview in parentView.subviews {
            if printSubviews {
                NSLog("\(String(repeating: "-", count: level))\(subview.viewInfo)")
            }
            result.append(subview)
            
            if subview.subviews.count != 0 {
                result += subviews(parentView: subview, level: level+1, printSubviews: printSubviews)
            }
        }
        return result
    }
    
    var allSubviews: [UIView] {
        return subviews(parentView: self)
    }
    
    func printSubviews() {
        _ = subviews(parentView: self, printSubviews: true)
    }
    
}

extension Selector {
    
    init(_ target: AnyObject, _ methodName: String, _ block: @escaping ()-> Void) {
        self.init(methodName)
        
        let imp: IMP = imp_implementationWithBlock(unsafeBitCast(block as @convention(block) ()-> Void, to: AnyObject.self))
        
        class_addMethod(target.classForCoder, self, imp, "v@")
    }
    
}

extension UIImage {
    
    /// IconFontからUIImageを生成する
    ///
    /// - Parameters:
    ///   - icon: IconFont名
    ///   - fontSize: 基のフォントサイズ (default: 20.0)
    ///   - rect: 生成する画像のサイズ (default: CGSize(width: 20.0, height: 20.0))
    ///   - color: 生成する画像の色 (default: .blue)
    /// - Returns: 画像
    class func iconFont(icon: IconFont,
                        fontSize: CGFloat = 20.0,
                        rect: CGSize = CGSize(width: 20.0, height: 20.0),
                        color: UIColor = .blue) -> UIImage? {
        
        guard let font = UIFont(name: "icomoon", size: fontSize) else { return nil }
        UIGraphicsBeginImageContextWithOptions(rect, false, 0.0)
        let attributes = [NSAttributedStringKey.foregroundColor: color,
                          NSAttributedStringKey.font: font]
        let attributedString = NSAttributedString(string: icon.rawValue,
                                                  attributes: attributes)
        
        let context = NSStringDrawingContext()
        let boundingRect = attributedString.boundingRect(with: CGSize(width: fontSize, height: fontSize),
                                                         options: .usesLineFragmentOrigin,
                                                         context: context)
        
        let imageRect = CGRect(x: (rect.width / 2.0) - (boundingRect.size.width / 2.0),
                               y: (rect.height / 2.0) - (boundingRect.size.height / 2.0),
                               width: rect.width,
                               height: rect.height)
        
        attributedString.draw(in: imageRect)
        let iconImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return iconImage
    }
}

