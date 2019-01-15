//
//  Message.swift
//  ChatApp
//
//  Created by Sovorn on 9/14/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var toId: String?
    var Text: String?
    var timeStamp: Int?
    
    var imageUrl: String?
    var width: NSNumber?
    var height: NSNumber?
    var videoUrl: String?
    
    func chatPartnerId() -> String? {
        return (fromId == Auth.auth().currentUser?.uid ? toId : fromId)!
    }
    
    init(dic: [String : AnyObject]){
        super.init()
        fromId  = dic["fromId"] as? String
        toId = dic["toId"] as? String
        Text = dic["Text"] as? String
        timeStamp = dic["timeStamp"] as? Int
        
        imageUrl = dic["imageUrl"] as? String
        width = dic["width"] as? NSNumber
        height = dic["height"] as? NSNumber
        videoUrl = dic["videoUrl"] as? String
    }
}
