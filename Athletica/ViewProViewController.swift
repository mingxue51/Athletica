//
//  ViewProViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/17/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ViewProViewController: UIViewController {

    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var viewFilterBg: UIView!
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblExtra: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var indicatorBlock: UIActivityIndicatorView!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var indicatorFollow: UIActivityIndicatorView!
    
    
    var user:User! // Init by SearchVC, BlockedUsersVC, FollowersVC, FollowingVC, FavoritesVC
    
    
    var following:[String:String]?
    var blockedUsers:[String:String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    func setupUI(){
        self.viewFilter.isHidden = true
        self.viewFilter.layer.cornerRadius = 5
        self.viewFilterBg.isHidden = true
        
        self.ivPhoto.layer.cornerRadius = 64.0
        if self.user.imageURL != "" {
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.indicatorType = .activity
            self.ivPhoto.kf.setImage(with: url)
        }
        
        self.lblName.text = self.user.firstName + " " + self.user.lastName
        self.lblCategory.text = self.user.category
        
        if self.user.city != "" && self.user.province != ""{
            self.lblLocation.text = self.user.city + ", " + self.user.province
        }else{
            self.lblLocation.text = ""
        }
        
        self.lblExtra.text = self.user.extra
        
        
        let nFollowers = self.user.follower.count
        self.lblFollowers.text = "\(nFollowers)"
        
        let nFollowing = self.user.following.count
        self.lblFollowing.text = "\(nFollowing)"
        
        
        // Check if the user is blocked or not
        self.blockedUsers = UserDefaults.standard.object(forKey: "blockedUsers") as? [String:String]
        if self.blockedUsers != nil && self.blockedUsers?[self.user.userId] != nil {
            self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
        }else{
            self.btnBlock.setTitle("BLOCK USER", for: .normal)
        }
        self.indicatorBlock.isHidden = true
        
        // Check if the user is one whom I'm following
        self.following = UserDefaults.standard.object(forKey: "following") as? [String:String]
        if self.following != nil && self.following?[self.user.userId] != nil {
            self.btnFollow.setImage(UIImage(named:"btnUnfollow"), for: .normal)
        }else{
            self.btnFollow.setImage(UIImage(named:"btnFollow"), for: .normal)
        }
        self.indicatorFollow.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Button actions
    @IBAction func btnDotsTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.viewFilter.isHidden = false
            
        }, completion: { (finished) -> Void in
            self.viewFilterBg.isHidden = false
        })
        
    }
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.closeFilterView()
    }
    func closeFilterView(){
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.viewFilter.isHidden = true
            
        }, completion: { (finished) -> Void in
            self.viewFilterBg.isHidden = true
        })
    }
    @IBAction func btnSendMessageTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        // Go to ChatContainerVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
        vc.receiverId = self.user.userId
        vc.receiverName = self.user.firstName + " " + self.user.lastName
        vc.receiverPhotoURL = self.user.imageURL
        vc.receiverUserType = self.user.userType
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func btnBlockTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "BLOCK USER"{
            // Block the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.blockUser(userId: self.user.userId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to block the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        self.blockedUsers = [:]
                    }
                    self.blockedUsers?[self.user.userId] = self.user.userId
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                }
            })
            
        }else{
            // Unblock the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.unblockUser(userId: self.user.userId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to unblock the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnBlock.setTitle("BLOCK USER", for: .normal)
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        return
                    }
                    self.blockedUsers?[self.user.userId] = nil
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                }
            })
        }
    }
    @IBAction func btnReportTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportUserViewController") as! ReportUserViewController
        vc.userId = self.user.userId
        vc.userName = self.user.firstName + " " + self.user.lastName
        vc.userType = self.user.userType
        vc.photoURL = self.user.imageURL
//        self.navigationController?.pushViewController(vc, animated: true)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnFollowTapped(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(named:"btnFollow"){
            // Follow the user
            self.btnFollow.isHidden = true
            self.indicatorFollow.isHidden = false
            self.indicatorFollow.startAnimating()
            FirebaseUtil.shared.followUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                if error != nil{
                    print(">>>Failed to follow the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFollow.setImage(UIImage(named:"btnUnfollow"), for: .normal)
                    // Save to UserDefaults
                    if self.following == nil{
                        self.following = [:]
                    }
                    self.following?[self.user.userId] = self.user.userId
                    UserDefaults.standard.set(self.following, forKey: "following")
                    
                    // Send a push notification to the creator
                    let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                    let message = "\(userName) is following you!"
                    self.sendNotification(message: message)
                    
                    // Update the user's follower dictionary
                    let myUserId = UserDefaults.standard.string(forKey: "userId")!
                    self.user.follower[myUserId] = myUserId
                    self.lblFollowers.text = "\(self.user.follower.count)"
                }
            })
            
        }else{
            // Unfollow the user
            self.btnFollow.isHidden = true
            self.indicatorFollow.isHidden = false
            self.indicatorFollow.startAnimating()
            FirebaseUtil.shared.unfollowUser(userId: self.user.userId, completion: { (error) in
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                if error != nil{
                    print(">>>Failed to unfollow the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnFollow.setImage(UIImage(named:"btnFollow"), for: .normal)
                    
                    // Save to UserDefaults
                    if self.following == nil{
                        return
                    }
                    self.following?[self.user.userId] = nil
                    UserDefaults.standard.set(self.following, forKey: "following")
                    
                    // Send a push notification to the creator
                    let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                    let message = "Oops! \(userName) unfollowed you!"
                    self.sendNotification(message: message)
                    
                    // Update the user's follower dictionary
                    let myUserId = UserDefaults.standard.string(forKey: "userId")!
                    self.user.follower[myUserId] = nil
                    self.lblFollowers.text = "\(self.user.follower.count)"
                }
            })
        }
    }
    func sendNotification(message:String){
        // If the user whom I'm following/unfollowing, doesn't want the push notifications, we don't send the notification
        if self.user.isSomeoneFollows == false {
            return
        }
        
        OneSignalUtil.shared.sendNotification(date: Date(), userIds: [self.user.oneSignalUserId], message: message, heading: nil)
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        var isPoped = false
        // Pop to BlockedUsersVC or SearchVC or AthleteProfileVC or ViewAthleteVC
        let controllers = self.navigationController!.viewControllers
        for index in (0...controllers.count-2).reversed() {
            let controller = controllers[index]
            if controller.isKind(of: BlockedUsersViewController.self) ||
                controller.isKind(of: SearchViewController.self) ||
                controller.isKind(of: AthleteProfileViewController.self) ||
                controller.isKind(of: ViewAthleteViewController.self){
                isPoped = true
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        if isPoped == false{
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func btnFollowersTapped(_ sender: UIButton) {
        if self.user.follower.count < 1{
            return
        }
//        navigateToVC(name: "FollowersViewController", fromVC: self, animated: true)
        // Go to FollowersVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFollowingTapped(_ sender: UIButton) {
        if self.user.following.count < 1{
            return
        }
        //        navigateToVC(name: "FollowingViewController", fromVC: self, animated: true)
        // Go to FollowingVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
