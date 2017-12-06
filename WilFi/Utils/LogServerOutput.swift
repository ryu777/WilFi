//
//  LogServerOutput.swift
//  WilFi
//
//  Created by Tatsuya Uemura on 2017/11/20.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import Puree

class LogServerOutput: PURBufferedOutput {
    override func configure(settings: [String : Any]) {
        super.configure(settings: settings)
    }

    override func write(chunk: PURBufferedOutputChunk, completion: @escaping (Bool) -> Void) {
        let logs = chunk.logs.map { (object: PURLog) -> NSDictionary in
            let log = object as PURLog
            var logDict = log.userInfo
            logDict["date"] = log.date
            return logDict as NSDictionary
        };

        var param = Server.params
        var p = ""
        
        let outputFormatter = DateFormatter()
        //ロケールを設定する。
        outputFormatter.locale = NSLocale(localeIdentifier:"ja_JP") as Locale!
        //フォーマットのスタイルを設定する。
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .medium
        
        let postDate = outputFormatter.string(from: logs[0]["date"] as! Date)
        param["postdate"] = postDate
        
        param["message"] = logs[0]["message"] as! String
        for (key, value) in param {
            NSLog("key:\(key) value:\(value)")
            
            var v = value as! String
            v = v.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.alphanumerics)!
            
            p += String(format:"%@=%@&",key,v)
//            p += key + "=" + value + "&"
        }
        
//        for key in param.keys as! [String] {
//            NSLog(key)
////            NSLog("key:\(key) value:\(param[key])")
//        }
//        let uid = param[""]
        
//        let message = logs[0]["message"] as! String
//        for content in logs {
//            NSLog(content["message"] as! String)
//        }
        
//        NSLog(logs[0]["message"] as! String)
        

        let url = URL(string: String(format: "https://watchdog.adcrops.net/uemura.html?%@",p))
        
//        let request = NSURLRequest(url: NSURL(string:"https://watchdog.adcrops.net/uemura.html")! as URL)
        let task = URLSession.shared.dataTask(with: url!) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            let httpResponse = response as! HTTPURLResponse
            if error != nil || httpResponse.statusCode != 200 {
                completion(false)
                return
            }
            completion(true)
        }
        task.resume()
        
//        do {
//            let logData = try JSONSerialization.data(withJSONObject: logs, options: [])
//            let request = NSURLRequest(url: NSURL(string:"https://watchdog.adcrops.net/uemura.html")! as URL)
//            let task =  URLSession.shared.uploadTask(with: request as URLRequest, from: logData, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
//                let httpResponse = response as! HTTPURLResponse
//                if error != nil || httpResponse.statusCode != 201 {
//                    completion(false)
//                    return
//                }
//                completion(true)
//            })
//            task.resume()
//        }catch {
//            completion(false)
//        }
    }
}

