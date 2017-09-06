//
//  Util.swift
//  Athletica
//
//  Created by SilverStar on 6/30/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation
import  UIKit


// Go to a view controller
func goToVC(name:String, fromVC:UIViewController, animated:Bool){
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: name)
    fromVC.present(vc, animated: animated, completion: nil)
}

// Go to a view controller
func navigateToVC(name:String, fromVC:UIViewController, animated:Bool){
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: name)
    fromVC.navigationController?.pushViewController(vc, animated: animated)
}

// Show alert
func showAlert(title:String?, message:String, controller:UIViewController?, okTitle:String, cancelTitle:String?, okAction: (()->())!, cancelAction: (()->())!){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: okTitle, style: .default, handler: { (action) in
        if okAction != nil {
            okAction()
        }
    })
    alert.addAction(ok)
    
    if cancelTitle != nil{
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
            if cancelAction != nil {
                cancelAction()
            }
        })
        alert.addAction(cancel)
    }
    
    if controller != nil {
        
        controller!.present(alert, animated: true, completion: nil)
    }else{
        // Get topViewController
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
}

// Validate an email
func isValidEmail(testStr:String) -> Bool {
    print("validate emilId: \(testStr)")
    let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

// Returns a trimmed string from string
func trimmedStringFromString(string:String) -> String{
    return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}

// Delete all keys and values from UserDefaults
func logout(){
    let appDomain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: appDomain)
    UserDefaults.standard.set(true, forKey: "isOnboarded")
}


// Subtract minutes from a date
func dateSubtracted(minutes:Int, from:Date) -> Date{

    let calendar = Calendar.current
    let newDate = calendar.date(byAdding: .minute, value: -minutes, to: from)
    return newDate!
    
}
// Subtract hours from a date
func dateSubtracted(hours:Int, from:Date) -> Date{
    
    let calendar = Calendar.current
    let newDate = calendar.date(byAdding: .hour, value: -hours, to: from)
    return newDate!
    
}

// Get time string from timestamp
func stringWithTimestamp(timestamp:Double)->String{
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
//    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "yyyy-MM-dd h:mm a" //Specify your format that you want
    
    
    // Get local timezone
    let localTimeZoneName = TimeZone.current.identifier
    let timeZoneAbbreviations: [String:String] = TimeZone.abbreviationDictionary
    dump(timeZoneAbbreviations)
    var keys = (timeZoneAbbreviations as NSDictionary).allKeys(for: localTimeZoneName) as! [String]
    if keys.count < 1{
        keys = []
        keys.append(localTimeZoneName)
    }
    let strDate = dateFormatter.string(from: date) + " " + keys[0]
    return strDate
}

// Get date string(e.g. 2/12/2017) from timestamp
func dateStringWithTimestamp(timestamp:Double)->String{
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
//    dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "M/dd/yyyy" //Specify your format that you want
    let strDate = dateFormatter.string(from: date)
    return strDate
}

// Decide if the athlete has purchased
func isPurchasedAthlete(timestamp:Double)->Bool{
    let currentTimestamp = Date().timeIntervalSince1970
    if timestamp >= currentTimestamp{
        return true
    }else{
        return false
    }
}


extension UIView {
    
    func dropShadow(scale: Bool = true) {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
