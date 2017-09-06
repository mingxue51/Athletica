//
//  Stream.swift
//  Athletica
//
//  Created by SilverStar on 7/8/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase

class Stream {
    var title:String = ""
    var category:String = ""
    var id:String = ""
    var type:String! // type can be upcoming/live/archived
    var resourceUri:String = ""

    var creatorId:String!
    var creatorName:String!
    
    var currentViewers:Int = 0
    var totalViewers:Int = 0
    
    var imageURL:String = ""
    var endedAt:Double = 0
    var startAt:Double = 0
    
    var invitedCoaches:[String:String]? // Used for upcoming streams, an array of <id, id> pairs
    
    var isSaveStream:Bool = false // If true, show the stream under the Streams tab on the Profile screen
    var creatorImageURL:String = ""
    
    func initWith(metadata:NSDictionary){
        self.title = metadata.value(forKey: "title") as! String
        self.id = metadata.value(forKey: "id") as! String
        self.type = metadata.value(forKey: "type") as! String
        self.resourceUri = metadata.value(forKey: "resourceUri") as! String
    }
    
    // Used when uploading
    func dictionary() -> [String:Any]{
        var res = [String:Any]()
        res["title"] = self.title
        res["category"] = self.category
        res["id"] = self.id
        res["type"] = self.type
        res["resourceUri"] = self.resourceUri
        res["creatorId"] = self.creatorId
        res["creatorName"] = self.creatorName
        res["currentViewers"] = self.currentViewers
        res["totalViewers"] = self.totalViewers
        res["imageURL"] = self.imageURL
        res["endedAt"] = ServerValue.timestamp()
        res["startAt"] = self.startAt
        if self.invitedCoaches != nil {
            res["invitedCoaches"] = self.invitedCoaches
        }
        res["isSaveStream"] = self.isSaveStream
        let creatorImageURL = UserDefaults.standard.string(forKey: "imageURL")
        if creatorImageURL != nil {
            self.creatorImageURL = creatorImageURL!
        }
        res["creatorImageURL"] = self.creatorImageURL
        return res
    }
    
    // Used to retrieve data from Firebase DB
    func initWithDic(dic:[String:Any]){
        self.title = dic["title"] as! String
        self.category = dic["category"] as! String
        self.id = dic["id"] as! String
        self.type = dic["type"] as! String
        self.resourceUri = dic["resourceUri"] as! String
        self.creatorId = dic["creatorId"] as! String
        self.creatorName = dic["creatorName"] as! String
        self.currentViewers = dic["currentViewers"] as! Int
        self.totalViewers = dic["totalViewers"] as! Int
        self.imageURL = dic["imageURL"] as! String
        self.endedAt = dic["endedAt"] as! Double
        self.startAt = dic["startAt"] as! Double
        self.isSaveStream = dic["isSaveStream"] as! Bool
        self.creatorImageURL = dic["creatorImageURL"] as! String
    }
}

