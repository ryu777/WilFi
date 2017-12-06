//
//  ActivityFilter.swift
//  WilFi
//
//  Created by Tatsuya Uemura on 2017/11/20.
//  Copyright © 2017年 Fancs. All rights reserved.
//

import Foundation

import Puree

class ActivityFilter: PURFilter {
    override func configure(settings: [String : Any]) {
        super.configure(settings: settings)
    }
    
    override func logs(object: Any, tag: String, captured: String?) -> [PURLog] {
        let currentDate = self.logger.currentDate()
        
        return [PURLog(tag: tag, date: currentDate, userInfo: ["message": object as Any])]
//
//        if let recipe = object as? Recipe {
//            return [PURLog(tag: tag, date: currentDate, userInfo: ["recipe_id": recipe.identifier, "recipe_title": recipe.title])]
//        } else if let bargainItem = object as? BargainItem {
//            return [PURLog(tag: tag, date: currentDate, userInfo: ["item_id": bargainItem.identifier, "item_name": bargainItem.name])]
//        }
//
//        return nil;
    }
//    override func logsWithObject(object: AnyObject!, tag: String!, captured: String!) -> [AnyObject]! {
//        let currentDate = self.logger.currentDate()
//
//        if let recipe = object as? Recipe {
//            return [PURLog(tag: tag, date: currentDate, userInfo: ["recipe_id": recipe.identifier, "recipe_title": recipe.title])]
//        } else if let bargainItem = object as? BargainItem {
//            return [PURLog(tag: tag, date: currentDate, userInfo: ["item_id": bargainItem.identifier, "item_name": bargainItem.name])]
//        }
//
//        return nil;
//    }
}

