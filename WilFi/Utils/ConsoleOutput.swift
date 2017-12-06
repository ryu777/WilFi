//
//  ConsoleOutput.swift
//  WilFi
//
//  Created by Tatsuya Uemura on 2017/11/20.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation
import Puree

class ConsoleOutput: PUROutput {
    override func configure(settings: [String : Any]) {
        super.configure(settings: settings)
    }

    override func emit(log: PURLog) {
        let outputFormatter = DateFormatter()
        //ロケールを設定する。
        outputFormatter.locale = NSLocale(localeIdentifier:"ja_JP") as Locale!
        //フォーマットのスタイルを設定する。
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .medium
        
        let postDate = outputFormatter.string(from: log.date)
        let message = log.userInfo["message"] as! String
//        NSLog("postdate: \(postDate), \(message)")
        print("[\(postDate)]:\(message)")

//        NSLog("tag: \(log.tag), date: \(log.date), \(log.userInfo)")
    }
//    override func emitLog(log: PURLog!) {
//        println("tag: \(log.tag), date: \(log.date), \(log.userInfo)")
//    }
}
