//
//  Network.swift
//  JobSeeking
//
//  Created by My Star on 3/3/17.
//  Copyright © 2017 Silver Star. All rights reserved.
//

import UIKit
import Alamofire



class Network: NSObject {    
    // Get metadata including resourceUri with broadcastId
    class func metadataWith(broadcastId: String, completion: @escaping (NSDictionary?) -> Void) {
        
        let url = "https://api.irisplatform.io/broadcasts/\(broadcastId)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Iris.apiKey)",
            "Content-Type": "application/json",
            "Accept": "application/vnd.bambuser.v1+json"
        ]
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while getting result: \(String(describing: response.result.error?.localizedDescription))")
                completion(nil)
                return
            }
            
            guard let responseJSON = response.result.value as? NSDictionary else {
                print("Invalid response received from the service")
                completion(nil)
                return
            }
            print(">>>Broadcast Info")
            print(responseJSON)
            completion(responseJSON)
        }
        
    }
    // Get download link for a stream with broadcastId
    class func downloadLinkWith(broadcastId: String, completion: @escaping (NSDictionary?) -> Void) {
        
        let url = "https://api.irisplatform.io/broadcasts/\(broadcastId)/downloads"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Iris.apiKey)",
            "Content-Type": "application/json",
            "Accept": "application/vnd.bambuser.v1+json"
        ]
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while getting result: \(String(describing: response.result.error?.localizedDescription))")
                completion(nil)
                return
            }
            
            guard let responseJSON = response.result.value as? NSDictionary else {
                print("Invalid response received from the service")
                completion(nil)
                return
            }
            print(">>>downloadLink Info")
            print(responseJSON)
            completion(responseJSON)
        }
        
    }
    
    class func coachSignup(firstName: String, lastName:String, email:String, password:String, category:String,
                           completion: @escaping (NSDictionary?) -> Void) {
        
        let url = baseUrl + "?action=coachSignup&firstName=\(firstName)&lastName=\(lastName)&email=\(email)&password=\(password)&category=\(category)"
        
        
        Alamofire.request(url).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while coachSignup: \(String(describing: response.result.error?.localizedDescription))")
                completion(nil)
                return
            }
            
            guard let responseJSON = response.result.value as? NSDictionary else {
                print("Invalid response received from the service")
                completion(nil)
                return
            }
            print(">>>Broadcast Info")
            print(responseJSON)
            completion(responseJSON)
        }
    }
    
    class func coachLogin(email:String, password:String,
                           completion: @escaping (NSDictionary?) -> Void) {
        
        let url = baseUrl + "?action=coachLogin&email=\(email)&password=\(password)"
        
        
        Alamofire.request(url).responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while coachLogin: \(String(describing: response.result.error?.localizedDescription))")
                completion(nil)
                return
            }
            
            guard let responseJSON = response.result.value as? NSDictionary else {
                print("Invalid response received from the service")
                completion(nil)
                return
            }
            print(">>>coachLogin response:")
            print(responseJSON)
            completion(responseJSON)
        }
    }

    // Report user
    // Called from ReportUserVC
    class func reportUser(userId: String, userName:String, userEmail:String, userType:String, text:String,
                          reporterId:String, reporterName:String, reporterEmail:String, reporterType:String,
                          completion: @escaping (NSDictionary?) -> Void) {

        let url = baseUrl + "?action=reportUser"
        let param:[String:String] = [
            "userId":userId,
            "userName":userName,
            "userEmail":userEmail,
            "userType":userType,
            "text":text,
            "reporterId":reporterId,
            "reporterName":reporterName,
            "reporterEmail":reporterEmail,
            "reporterType":reporterType
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print(">>>Error while reportUser: \(String(describing: response.result.error?.localizedDescription))")
                    completion(nil)
                    return
                }
                
                guard let responseJSON = response.result.value as? NSDictionary else {
                    print("Invalid response received from the service")
                    completion(nil)
                    return
                }
                print(">>>reportUser response:")
                print(responseJSON)
                completion(responseJSON)
        }

    }
    
    // Send feedback
    // Called from SendFeedbackVC
    class func sendFeedback(text:String,
                          reporterId:String, reporterName:String, reporterEmail:String, reporterType:String,
                          completion: @escaping (NSDictionary?) -> Void) {
        
        let url = baseUrl + "?action=sendFeedback"
        let param:[String:String] = [
            "text":text,
            "reporterId":reporterId,
            "reporterName":reporterName,
            "reporterEmail":reporterEmail,
            "reporterType":reporterType
        ]
        
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print(">>>Error while reportUser: \(String(describing: response.result.error?.localizedDescription))")
                    completion(nil)
                    return
                }
                
                guard let responseJSON = response.result.value as? NSDictionary else {
                    print("Invalid response received from the service")
                    completion(nil)
                    return
                }
                print(">>>reportUser response:")
                print(responseJSON)
                completion(responseJSON)
        }
        
    }
   
}
