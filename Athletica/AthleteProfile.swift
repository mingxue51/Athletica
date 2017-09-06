//
//  AthleteProfile.swift
//  Athletica
//
//  Created by SilverStar on 8/3/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//
// This class includes the info of About and Stats.
// Used as a member object of the User class.

import UIKit

class AthleteProfile: NSObject {
//    var userId:String = ""
//    var photoURL:String = ""
//    
//    var fullName:String = ""
//    var category:String = ""
//    
//    var followers:Int = 0
//    var following:Int = 0
    
    // Bio
    var height:String = ""
    var weight:String = ""
//    var state:String = ""
//    var city:String = ""
    var classOf:String = ""
    var phone:String = ""
    
    // Honors and Awards
    var honorsAwards: String = ""
    
    // School and Education
    var schoolName:String = ""
    var schoolZipCode:String = ""
    var gpa:String = ""
    var actScore:String = ""
    var satScore:String = ""
    var apCredits:String = ""
    
    // Volunteering
    var volunteering:String = ""
    
    // Sports Stats
    // According to category, there are upto 13 variables
    var stat1:String = ""
    var stat2:String = ""
    var stat3:String = ""
    var stat4:String = ""
    var stat5:String = ""
    var stat6:String = ""
    var stat7:String = ""
    var stat8:String = ""
    var stat9:String = ""
    var stat10:String = ""
    var stat11:String = ""
    var stat12:String = ""
    var stat13:String = ""
    
    // Highlights & Other Stats
    var other:String = ""
    
    
//    override init() {
//        let firstName = UserDefaults.standard.string(forKey: "firstName")
//        let lastName = UserDefaults.standard.string(forKey: "lastName")
//        userId = UserDefaults.standard.string(forKey: "userId")!
//        fullName = firstName! + " " + lastName!
//        category = UserDefaults.standard.string(forKey: "category")!
//    }

    func initWithDic(dic:[String:Any]){
//        self.photoURL = dic["photoURL"] as! String
//        
//        self.followers = dic["followers"] as! Int
//        self.following = dic["following"] as! Int
        
        self.height = dic["height"] as! String
        self.weight = dic["weight"] as! String
//        self.state = dic["state"] as! String
//        self.city = dic["city"] as! String
        self.classOf = dic["classOf"] as! String
        self.phone = dic["phone"] as! String
        
        self.honorsAwards = dic["honorsAwards"] as! String
        
        self.schoolName = dic["schoolName"] as! String
        self.schoolZipCode = dic["schoolZipCode"] as! String
        self.gpa = dic["gpa"] as! String
        self.actScore = dic["actScore"] as! String
        self.satScore = dic["satScore"] as! String
        self.apCredits = dic["apCredits"] as! String
        
        self.volunteering = dic["volunteering"] as! String
        
        self.stat1 = dic["stat1"] as! String
        self.stat2 = dic["stat2"] as! String
        self.stat3 = dic["stat3"] as! String
        self.stat4 = dic["stat4"] as! String
        self.stat5 = dic["stat5"] as! String
        self.stat6 = dic["stat6"] as! String
        self.stat7 = dic["stat7"] as! String
        self.stat8 = dic["stat8"] as! String
        self.stat9 = dic["stat9"] as! String
        self.stat10 = dic["stat10"] as! String
        self.stat11 = dic["stat11"] as! String
        self.stat12 = dic["stat12"] as! String
        self.stat13 = dic["stat13"] as! String
        
        self.other = dic["other"] as! String
        
    }
    
    func dictionary() -> [String:Any]{
        var res = [String:Any]()
//        res["userId"] = self.userId
//        res["photoURL"] = self.photoURL
//        res["fullName"] = self.fullName
//        res["category"] = self.category
//        res["followers"] = self.followers
//        res["following"] = self.following
        res["height"] = self.height
        res["weight"] = self.weight
//        res["state"] = self.state
//        res["city"] = self.city
        res["classOf"] = self.classOf
        res["phone"] = self.phone
        res["honorsAwards"] = self.honorsAwards
        res["schoolName"] = self.schoolName
        res["schoolZipCode"] = self.schoolZipCode
        res["gpa"] = self.gpa
        res["actScore"] = self.actScore
        res["satScore"] = self.satScore
        res["apCredits"] = self.apCredits
        res["volunteering"] = self.volunteering
        res["stat1"] = self.stat1
        res["stat2"] = self.stat2
        res["stat3"] = self.stat3
        res["stat4"] = self.stat4
        res["stat5"] = self.stat5
        res["stat6"] = self.stat6
        res["stat7"] = self.stat7
        res["stat8"] = self.stat8
        res["stat9"] = self.stat9
        res["stat10"] = self.stat10
        res["stat11"] = self.stat11
        res["stat12"] = self.stat12
        res["stat13"] = self.stat13
        res["other"] = self.other
        
        return res
    }
    
    func initWith(profile:AthleteProfile){
//        self.userId = profile.userId
//        self.photoURL = profile.photoURL
//        self.fullName = profile.fullName
//        self.category = profile.category
//        self.followers = profile.followers
//        self.following = profile.following
        self.height = profile.height
        self.weight = profile.weight
//        self.state = profile.state
//        self.city = profile.city
        self.classOf = profile.classOf
        self.phone = profile.phone
        self.honorsAwards = profile.honorsAwards
        self.schoolName = profile.schoolName
        self.schoolZipCode = profile.schoolZipCode
        self.gpa = profile.gpa
        self.actScore = profile.actScore
        self.satScore = profile.satScore
        self.apCredits = profile.apCredits
        self.volunteering = profile.volunteering
        self.stat1 = profile.stat1
        self.stat2 = profile.stat2
        self.stat3 = profile.stat3
        self.stat4 = profile.stat4
        self.stat5 = profile.stat5
        self.stat6 = profile.stat6
        self.stat7 = profile.stat7
        self.stat8 = profile.stat8
        self.stat9 = profile.stat9
        self.stat10 = profile.stat10
        self.stat11 = profile.stat11
        self.stat12 = profile.stat12
        self.stat13 = profile.stat13
        self.other = profile.other
    }
}
