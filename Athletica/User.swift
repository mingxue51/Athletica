//
//  self.swift
//  Athletica
//
//  Created by SilverStar on 7/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId:String = ""
    var userType:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var category:String = ""
    var email:String = ""
    
    var city:String = ""
    var province:String = "" // Equal to a state of the US
    
    var imageURL:String = ""
    var oneSignalUserId:String = ""
    
    var state:String = ""
    
    var isPrivate:Bool = false // Whether the user account is private or not - true or false
    var isSomeoneFollows:Bool = false // Send notifications if someone follows the user
    var isScheduledStream:Bool = true // Send notifications as a scheduled stream reminder
    var isFriendStarts:Bool = true // Send notifications if friend starts a stream
    var isInvites:Bool = true // Send notifications if an athlete invites her to a stream
    var expiryTimestamp:Double = 0 // Shows timestamp of the expiry date
    
    var authorizedUsers:[String:String] = [:]   // This dictionary includes pairs of authorized user's id and myFullName_myUserType
                                                // Used in AuthorizedUsersVC and StartLiveStreamVC
    var blockedUsers:[String:String] = [:]
    var favoriteUsers:[String:String] = [:] // Used for coaches only
    var following:[String:String] = [:] // Users whom the user is following. This dictionary includes pairs of following user's id
    var follower:[String:String] = [:] // Users who follow the user
    
    var athleteProfile:AthleteProfile? // Used for athletes only
    
    var extra:String = "" // Used for coaches and pros, it is School name for coaches, and Short intro for pros
    
    var nSavedStreams:Int = 0 // The number of saved streams. It's NOT saved in UserDefaults, only in Firebase DB.
    
    
    // Called from AthleteEditProfileVC
    func initWithUser(user:User){
        self.userId = user.userId
        self.userType = user.userType
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.category = user.category
        self.email = user.email
        
        self.city = user.city
        self.province = user.province
        
        self.imageURL = user.imageURL
        self.oneSignalUserId = user.oneSignalUserId
        
        self.state = user.state
        
        self.isPrivate = user.isPrivate
        self.isSomeoneFollows = user.isSomeoneFollows
        self.isScheduledStream = user.isScheduledStream
        self.isFriendStarts = user.isFriendStarts
        self.isInvites = user.isInvites
        self.expiryTimestamp = user.expiryTimestamp
        
        self.authorizedUsers = user.authorizedUsers
        self.blockedUsers = user.blockedUsers
        self.favoriteUsers = user.favoriteUsers
        self.following = user.following
        self.follower = user.follower
        
        self.athleteProfile = user.athleteProfile
        
        self.extra = user.extra
        
        self.nSavedStreams = user.nSavedStreams
    }
    
    
    // Used after sign up to upload user info
    func initWith(userId:String, userType:String, firstName:String, lastName:String, category:String,
                  email:String, imageURL:String, oneSignalUserId:String, state:String, isPrivate:Bool,
                  isSomeoneFollows:Bool, isScheduledStream:Bool, isFriendStarts:Bool, isInvites:Bool, expiryTimestamp:Double){
        self.userId = userId
        self.userType = userType
        self.firstName = firstName
        self.lastName = lastName
        self.category = category
        self.email = email
        self.imageURL = imageURL
        self.oneSignalUserId = oneSignalUserId
        self.state = state
        self.isPrivate = isPrivate
        self.isSomeoneFollows = isSomeoneFollows
        self.isScheduledStream = isScheduledStream
        self.isFriendStarts = isFriendStarts
        self.isInvites = isInvites
        self.expiryTimestamp = expiryTimestamp
        
        if userType == UserType.athlete.rawValue{
            self.athleteProfile = AthleteProfile()
        }
    }
    // Used after sign up to upload user info
    // Also used when update the user profile
    func dictionary() -> [String:Any]{
        var userDic:[String:Any] = [:]
        
        userDic["userId"] = self.userId
        userDic["userType"] = self.userType
        userDic["firstName"] = self.firstName
        userDic["lastName"] = self.lastName
        userDic["category"] = self.category
        userDic["email"] = self.email
        
        userDic["city"] = self.city
        userDic["province"] = self.province
        
        userDic["imageURL"] = self.imageURL
        userDic["oneSignalUserId"] = self.oneSignalUserId
        userDic["state"] = self.state
        
        userDic["isPrivate"] = self.isPrivate
        userDic["isSomeoneFollows"] = self.isSomeoneFollows
        userDic["isScheduledStream"] = self.isScheduledStream
        userDic["isFriendStarts"] = self.isFriendStarts
        userDic["isInvites"] = self.isInvites
        userDic["expiryTimestamp"] = self.expiryTimestamp
        
//        userDic["authorizedUsers"] = self.authorizedUsers
//        userDic["blockedUsers"] = self.blockedUsers
//        userDic["following"] = self.following
//        userDic["follower"] = self.follower
        
        if userType == UserType.athlete.rawValue{
            userDic["athleteProfile"] = self.athleteProfile?.dictionary()
        }
        
        userDic["extra"] = self.extra
        
        userDic["nSavedStreams"] = self.nSavedStreams
        
        return userDic
    }
    
    // Used when retrieve data from Firebase DB
    func initWithDic(dic:[String:Any]){
        
        self.userId = dic["userId"] as! String
        self.userType = dic["userType"] as! String
        self.firstName = dic["firstName"] as! String
        self.lastName = dic["lastName"] as! String
        self.category = dic["category"] as! String
        self.email = dic["email"] as! String
        
        self.city = dic["city"] as! String
        self.province = dic["province"] as! String
        
        self.imageURL = dic["imageURL"] as! String
        self.oneSignalUserId = dic["oneSignalUserId"] as! String
        self.state = dic["state"] as! String
        
        self.isPrivate = dic["isPrivate"] as! Bool
        self.isSomeoneFollows = dic["isSomeoneFollows"] as! Bool
        self.isScheduledStream = dic["isScheduledStream"] as! Bool
        self.isFriendStarts = dic["isFriendStarts"] as! Bool
        self.isInvites = dic["isInvites"] as! Bool
        if let timestamp = dic["expiryTimestamp"]{
            self.expiryTimestamp = timestamp as! Double
        }
        
        if let temp = dic["authorizedUsers"]{
            self.authorizedUsers = temp as! [String:String]
        }
        if let temp = dic["blockedUsers"]{
            self.blockedUsers = temp as! [String:String]
        }
        if let temp = dic["favoriteUsers"]{
            self.favoriteUsers = temp as! [String:String]
        }
        if let temp = dic["following"]{
            self.following = temp as! [String:String]
        }
        if let temp = dic["follower"]{
            self.follower = temp as! [String:String]
        }
        if let temp = dic["athleteProfile"]{
            self.athleteProfile = AthleteProfile()
            self.athleteProfile?.initWithDic(dic: temp as! [String:Any])
        }
        
        if let temp = dic["extra"]{
            self.extra = temp as! String
        }
        
        if let temp = dic["nSavedStreams"]{
            self.nSavedStreams = temp as! Int
        }
        
    }
    
    // Called in SettingsVC, AthleteProfileVC, ...
    func initWithUserDefaults(){
        self.userId = UserDefaults.standard.string(forKey: "userId")!
        self.userType = UserDefaults.standard.string(forKey: "userType")!
        self.firstName = UserDefaults.standard.string(forKey: "firstName")!
        self.lastName = UserDefaults.standard.string(forKey: "lastName")!
        self.category = UserDefaults.standard.string(forKey: "category")!
        self.email = UserDefaults.standard.string(forKey: "email")!
        
        self.city = UserDefaults.standard.string(forKey: "city")!
        self.province = UserDefaults.standard.string(forKey: "province")!
        
        self.imageURL = UserDefaults.standard.string(forKey: "imageURL")!
        self.oneSignalUserId = UserDefaults.standard.string(forKey: "oneSignalUserId")!
        self.state = UserDefaults.standard.string(forKey: "state")!
        
        self.isPrivate = UserDefaults.standard.bool(forKey: "isPrivate")
        self.isSomeoneFollows = UserDefaults.standard.bool(forKey: "isSomeoneFollows")
        self.isScheduledStream = UserDefaults.standard.bool(forKey: "isScheduledStream")
        self.isFriendStarts = UserDefaults.standard.bool(forKey: "isFriendStarts")
        self.isInvites = UserDefaults.standard.bool(forKey: "isInvites")
        self.expiryTimestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
        
        
        self.authorizedUsers = UserDefaults.standard.object(forKey: "authorizedUsers") as! [String : String]
        self.blockedUsers = UserDefaults.standard.object(forKey: "blockedUsers") as! [String : String]
        
        if let favoriteUsers = UserDefaults.standard.object(forKey: "favoriteUsers"){
            self.favoriteUsers =  favoriteUsers as! [String : String]
        }
        self.following = UserDefaults.standard.object(forKey: "following") as! [String : String]
        self.follower = UserDefaults.standard.object(forKey: "follower") as! [String : String]
        
        if let extra = UserDefaults.standard.string(forKey: "extra"){
            self.extra = extra
        }
        
//        if let nSavedStreams = UserDefaults.standard.object(forKey: "nSavedStreams"){
//            self.nSavedStreams = nSavedStreams as! Int
//        }
        
        
    }
    
    
    
    func saveToUserDefaults(){
        // Save userInfo in UserDefaults
        UserDefaults.standard.set(self.userId, forKey: "userId")
        UserDefaults.standard.set(self.userType, forKey: "userType")
        UserDefaults.standard.set(self.firstName, forKey: "firstName")
        UserDefaults.standard.set(self.lastName, forKey: "lastName")
        UserDefaults.standard.set(self.category, forKey: "category")
        UserDefaults.standard.set(self.email, forKey: "email")
        
        UserDefaults.standard.set(self.city, forKey: "city")
        UserDefaults.standard.set(self.province, forKey: "province")
        
        UserDefaults.standard.set(self.imageURL, forKey: "imageURL")
        UserDefaults.standard.set(self.oneSignalUserId, forKey: "oneSignalUserId")
        UserDefaults.standard.set(self.state, forKey: "state")
        
        UserDefaults.standard.set(self.isPrivate, forKey: "isPrivate")
        UserDefaults.standard.set(self.isSomeoneFollows, forKey: "isSomeoneFollows")
        UserDefaults.standard.set(self.isScheduledStream, forKey: "isScheduledStream")
        UserDefaults.standard.set(self.isFriendStarts, forKey: "isFriendStarts")
        UserDefaults.standard.set(self.isInvites, forKey: "isInvites")
        UserDefaults.standard.set(self.expiryTimestamp, forKey: "expiryTimestamp")
        
        UserDefaults.standard.set(self.authorizedUsers, forKey: "authorizedUsers")
        UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
        UserDefaults.standard.set(self.favoriteUsers, forKey: "favoriteUsers")
        UserDefaults.standard.set(self.following, forKey: "following")
        UserDefaults.standard.set(self.follower, forKey: "follower")
        
        UserDefaults.standard.set(self.extra, forKey: "extra")
        
//        UserDefaults.standard.set(self.nSavedStreams, forKey: "nSavedStreams")
        
        UserDefaults.standard.synchronize()
    }
}
