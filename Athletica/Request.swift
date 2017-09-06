//
//  Request.swift
//  Athletica
//
//  Created by SilverStar on 8/31/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase

class Request: NSObject {
    var requestId:String = ""
    
    var senderId:String = ""
    var senderName:String = ""
    var senderPhotoURL:String = ""
    var senderType:String = "" // Teammate or something
    
    var receiverId:String = ""
    
    var isApproved:Bool = false // Shows if the athlete approved the kudo. Used in Messages and AthleteProfile VCs
    var timestamp:Double = 1503175379 // When the kudo was sent
    
    func initWith(senderId:String, senderName:String, senderPhotoURL:String, senderType:String,
                  receiverId:String){
        self.senderId = senderId
        self.senderName = senderName
        self.senderPhotoURL = senderPhotoURL
        self.senderType = senderType
        self.receiverId = receiverId
    }
    
    func dictionary() -> [String:Any]{
        var res = [String:Any]()
        res["requestId"] = self.requestId
        res["senderId"] = self.senderId
        res["senderName"] = self.senderName
        res["senderPhotoURL"] = self.senderPhotoURL
        res["senderType"] = self.senderType
        res["receiverId"] = self.receiverId
        res["isApproved"] = self.isApproved
        res["timestamp"] = ServerValue.timestamp()
        return res
    }
    
    func initWithDic(dic:[String:Any]){
        self.requestId = dic["requestId"] as! String
        self.senderId = dic["senderId"] as! String
        self.senderName = dic["senderName"] as! String
        self.senderPhotoURL = dic["senderPhotoURL"] as! String
        self.senderType = dic["senderType"] as! String
        self.receiverId = dic["receiverId"] as! String
        if let temp = dic["isApproved"] as? Bool{
            self.isApproved = temp
        }
        if let temp = dic["timestamp"] as? Double{
            self.timestamp = temp/1000.0
        }
    }

}
