//
//  MessagingUser.swift
//  Athletica
//
//  Created by SilverStar on 8/19/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

// Users who I have messages with
class MessagingUser: NSObject {
    var userId:String = ""
    var imageURL:String = ""
    var userName:String = ""
    var userType:String = ""
    var timestamp:Double!
    
    // Called when retrieving data from Firebase DB
    func initWithDic(dic:[String:Any]){
        let senderId = dic["senderId"] as! String
        let senderName = dic["senderName"] as! String
        let senderPhotoURL = dic["senderPhotoURL"] as! String
        let senderUserType = dic["senderUserType"] as! String
        let receiverId = dic["receiverId"] as! String
        let receiverName = dic["receiverName"] as! String
        let receiverPhotoURL = dic["receiverPhotoURL"] as! String
        let receiverUserType = dic["receiverUserType"] as! String
        let timestamp = dic["timestamp"] as! Double
        
        let myUserId = UserDefaults.standard.string(forKey: "userId")!
        if myUserId != senderId{ // This message was sent by the other user
            self.userId = senderId
            self.imageURL = senderPhotoURL
            self.userName = senderName
            self.userType = senderUserType
            
        }else{
            self.userId = receiverId
            self.imageURL = receiverPhotoURL
            self.userName = receiverName
            self.userType = receiverUserType
        }
        
        self.timestamp = timestamp/1000.0
    }
}
