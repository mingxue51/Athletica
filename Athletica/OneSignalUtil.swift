//
//  OneSignalUtil.swift
//  Athletica
//
//  Created by SilverStar on 8/15/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation
import OneSignal

class OneSignalUtil {
    
    static let shared = OneSignalUtil()
    
    // Send notifications for following, etc
    func sendNotification(date:Date, userIds:[String], message:String, heading:String!){
        // See the Create notification REST API POST call for a list of all possible options: https://documentation.onesignal.com/reference#create-notification
        // NOTE: You can only use include_player_ids as a targeting parameter from your app. Other target options such as tags and included_segments require your OneSignal App REST API key which can only be used from your server.
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let pushToken = status.subscriptionStatus.pushToken
                
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let strDate = formatter.string(from: date)
        
        
//        if pushToken != nil {
            var notificationContent = [
                "include_player_ids": userIds,
                "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
//                "headings": ["en": heading],
                //                "subtitle": ["en": "An English Subtitle"],
                // If want to open a url with in-app browser
                //"url": "https://google.com",
                // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                //                "data": ["OpenURL": "https://imgur.com"],
                //                "ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                "ios_badgeType": "Increase",
                "ios_badgeCount": 1,
                "send_after": strDate
                ] as [String : Any]
            if heading != nil{
                notificationContent["headings"] = ["en": heading]
            }
            
            OneSignal.postNotification(notificationContent)
            print(">>>Notification sent")
//        }
    }
    
    // Send notifications for missing messages
    // Called from ChatVC
    func sendMessageNotification(date:Date, userIds:[String], message:String, heading:String!,
                                 userId:String, userName:String, userPhotoURL:String, userType:String){
        // See the Create notification REST API POST call for a list of all possible options: https://documentation.onesignal.com/reference#create-notification
        // NOTE: You can only use include_player_ids as a targeting parameter from your app. Other target options such as tags and included_segments require your OneSignal App REST API key which can only be used from your server.
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let pushToken = status.subscriptionStatus.pushToken
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        let strDate = formatter.string(from: date)
        
        
        //        if pushToken != nil {
        var notificationContent = [
            "include_player_ids": userIds,
            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
            //                "headings": ["en": heading],
            //                "subtitle": ["en": "An English Subtitle"],
            // If want to open a url with in-app browser
            //"url": "https://google.com",
            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
            "data": ["userId": userId, "userName":userName, "userPhotoURL":userPhotoURL, "userType":userType],
            //                "ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
            "ios_badgeType": "Increase",
            "ios_badgeCount": 1,
            "send_after": strDate
            ] as [String : Any]
        if heading != nil{
            notificationContent["headings"] = ["en": heading]
        }
        
        OneSignal.postNotification(notificationContent)
        print(">>>Notification sent")
        //        }
    }

}
