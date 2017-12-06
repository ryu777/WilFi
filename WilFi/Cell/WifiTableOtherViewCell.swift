//
//  WifiTableOtherViewCell.swift
//  WilFi
//
// 周辺のWifi一覧のCell
//
//  Created by Tatsuya Uemura on 2017/10/19.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import MapKit

class WifiTableOtherViewCell: UITableViewCell {
    
    var parent:ViewController!
    
    @IBOutlet weak var wifiIconView: TopRoundImageView!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var useCountLabel: UILabel!
    @IBOutlet weak var usersIconView:UIImageView!

    var isWifiConnected:Bool = false
    
    var wifi:WifiInfo?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        self.usersIconView.image = UIImage.iconFont(icon: .users, fontSize: 20.0, rect: CGSize.init(width: 15.0, height: 25), color: UIColor.rgb(r: 171, g: 177, b: 223, alpha: 1))!

    }

    func set(wifi:WifiInfo) {
        self.wifi = wifi
        self.wifiLabel.text = wifi.spotName
        self.detailLabel.text = wifi.detail
        self.useCountLabel.text = wifi.connectionCount.withComma

        self.wifiIconView.af_setImage(withURL: URL(string: wifi.iconUrl)!,placeholderImage:UIImage(named: "placeholder"))
        
        
        self.distanceLabel.text = String(format: "%@m以内",wifi.distance.withComma)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        guard let myLocation = appDelegate.myLocation else {
            return
        }
        let d:Double = myLocation.distance(from: CLLocation(latitude: wifi.latitude, longitude: wifi.longitude))
        self.distanceLabel.text = String(format: "%@m以内",Int(d).withComma)

    }
    
    @IBAction func openMap(_ sender: Any) {
        NSLog("openMap")
//        let urlString =  String(format: "http://maps.apple.com/maps?ll=%1.6f,%1.6f&q=%@&z=10&spn=100",
//                                (self.wifi?.latitude)!,(self.wifi?.longitude)!,(self.wifi?.spotName)!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!)
//        UIApplication.shared.open(NSURL(string: urlString)! as URL, options: [:], completionHandler: nil)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        guard let myLocation = appDelegate.myLocation else {
            return
        }

        if UserDefaults.standard.integer(forKey: "sbMapApp") == 2 {
            // GoogleMap
            let saddr = "saddr=\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)"
            let daddr = "daddr=\((self.wifi?.latitude)!),\((self.wifi?.longitude)!)"
            let destinationURL = Settings.GOOGLE_MAP_URL_SCHEME + "?" + saddr + "&" + daddr + "&directionsmode=walking"
            if let url = URL(string: destinationURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        }
        
        let sourceCoodinate = CLLocationCoordinate2D(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoodinate, addressDictionary: nil)
        let source = MKMapItem(placemark: sourcePlaceMark)
        source.name = "現在地"
        
        let destinationCoodinate = CLLocationCoordinate2D(latitude: (self.wifi?.latitude)!, longitude: (self.wifi?.longitude)!)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoodinate, addressDictionary: nil)
        let destination = MKMapItem(placemark: destinationPlaceMark)
//        let storeName = self.aVenue?.storeName
//        let shopName = self.aVenue?.name
//        destination.name = (self.wifi?.spotName)!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
        destination.name = (self.wifi?.spotName)!

        // 始点を中心にして10kmの範囲で領域を作成する。
        let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, 10000, 10000);
        
        let options:[String : Any] = [
                        MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking, // 徒歩
//                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center), // マップの中心座標を指定する
//                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span) // マップの表示範囲を指定する
        ]
        let array = [source, destination]
        
        let result = MKMapItem.openMaps(with: array, launchOptions: options)
        if !result {
        }

        
    }
}
