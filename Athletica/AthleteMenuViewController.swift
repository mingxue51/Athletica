//
//  AthleteMenuViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/30/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SideMenu

class AthleteMenuViewController: UIViewController {
    
    var newsVC: AthleteNewsViewController?
    var profileVC: AthleteProfileViewController?
    
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var btnWhos: UIButton!
    @IBOutlet weak var ivLock: UIImageView!
    
    
    let userType = UserDefaults.standard.string(forKey: "userType")
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI(){
        let userType = UserDefaults.standard.string(forKey: "userType")
        // Hide btnUpgrade if not an athlete
        if userType != UserType.athlete.rawValue {
            self.btnUpgrade.isHidden = true
        }
        
        // Hide btnUpgrade if the Athlete has paid
        if userType == UserType.athlete.rawValue{
            let timestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
            if isPurchasedAthlete(timestamp: timestamp){
                self.btnUpgrade.isHidden = true
            }else{
                self.btnUpgrade.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Button Actions
    @IBAction func btnMenuTapped(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
   
    @IBAction func btnLogoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            logout()
            self.dismiss(animated: true){
                // Go to VC
                if let topController = UIApplication.topViewController() {
                    goToVC(name: "ViewController", fromVC: topController, animated: false)
                }
                
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func btnNewsTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            if let topController = UIApplication.topViewController() {
                if topController is AthleteNewsViewController{ return }
                navigateToVC(name: "AthleteNewsViewController", fromVC: topController, animated: false)
            }
        }
        
    }

    @IBAction func btnProfileTapped(_ sender: Any) {
        
        if self.userType == UserType.athlete.rawValue {
            self.dismiss(animated: true){
                
                if let topController = UIApplication.topViewController() {
                    if topController is AthleteProfileViewController {
                        return
                    }
                    // Go to AthleteProfileViewController
                    navigateToVC(name: "AthleteProfileViewController", fromVC: topController, animated: false)
                }
                
            }
        }else if self.userType == UserType.proAthlete.rawValue {
            self.dismiss(animated: true){
                
                if let topController = UIApplication.topViewController() {
                    if topController is ProProfileViewController {
                        return
                    }
                    // Go to ProProfileViewController
                    navigateToVC(name: "ProProfileViewController", fromVC: topController, animated: false)
                }
                
            }
        }else if self.userType == UserType.coach.rawValue {
            self.dismiss(animated: true){
                
                if let topController = UIApplication.topViewController() {
                    if topController is CoachProfileViewController {
                        return
                    }
                    // Go to CoachProfileViewController
                    navigateToVC(name: "CoachProfileViewController", fromVC: topController, animated: false)
                }
                
            }
            
        }else if self.userType == UserType.fan.rawValue {
            self.dismiss(animated: true){
                
                if let topController = UIApplication.topViewController() {
                    if topController is FanProfileViewController {
                        return
                    }
                    // Go to FanProfileViewController
                    navigateToVC(name: "FanProfileViewController", fromVC: topController, animated: false)
                }
                
            }
        }else{
            
        }
        
    }
    
    @IBAction func btnStreamsTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is AthleteStreamsViewController {
                    return
                }
                // Go to AthleteStreamsViewController
                navigateToVC(name: "AthleteStreamsViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnSearchTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is SearchViewController {
                    return
                }
                // Go to SearchViewController
                navigateToVC(name: "SearchViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnUpcomingTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is UpcomingStreamsViewController {
                    return
                }
                // Go to UpcomingStreamsViewController
                navigateToVC(name: "UpcomingStreamsViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnUpgradeTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is UpgradeViewController {
                    return
                }
                // Go to UpgradeViewController
                navigateToVC(name: "UpgradeViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnSettingsTapped(_ sender: UIButton) {
//        if self.userType == UserType.coach.rawValue{
//            self.dismiss(animated: true){
//                
//                if let topController = UIApplication.topViewController() {
//                    if topController is CoachSettingsViewController {
//                        return
//                    }
//                    // Go to CoachSettingsViewController
//                    navigateToVC(name: "CoachSettingsViewController", fromVC: topController, animated: false)
//                }
//                
//            }
//        }else{
            self.dismiss(animated: true){
                
                if let topController = UIApplication.topViewController() {
                    if topController is SettingsViewController {
                        return
                    }
                    // Go to SettingsViewController
                    navigateToVC(name: "SettingsViewController", fromVC: topController, animated: false)
                }
                
            }
//        }
    }
    @IBAction func btnPrivacyTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is PrivacyViewController {
                    return
                }
                // Go to PrivacyViewController
                goToVC(name: "PrivacyViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnTermsTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            
            if let topController = UIApplication.topViewController() {
                if topController is TermsViewController {
                    return
                }
                // Go to TermsViewController
                goToVC(name: "TermsViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnSendFeedbackTapped(_ sender: UIButton) {
        self.dismiss(animated: true){
            if let topController = UIApplication.topViewController() {
                if topController is TermsViewController {
                    return
                }
                // Go to SendFeedbackViewController
                goToVC(name: "SendFeedbackViewController", fromVC: topController, animated: false)
            }
            
        }
    }
    
    @IBAction func btnRateTapped(_ sender: UIButton) {
        let appID = "1275160023"
        let reviewString = "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8&action=write-review"
        
        if let checkURL = URL(string: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(appID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8") {
            open(url: checkURL)
        } else {
            print("invalid url")
        }
//        rateApp(appId: "id1130653804") { success in
//            print("RateApp \(success)")
//        }
    }
//    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
//        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
//            completion(false)
//            return
//        }
//        guard #available(iOS 10, *) else {
//            completion(UIApplication.shared.openURL(url))
//            return
//        }
//        UIApplication.shared.open(url, options: [:], completionHandler: completion)
//    }
    func open(url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else if UIApplication.shared.openURL(url) {
            print("invalid url")
        }
    }
    
    
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}


