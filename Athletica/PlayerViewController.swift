//
//  PlayerViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/16/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class PlayerViewController: BaseViewController, BambuserPlayerDelegate  {
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ivUsers: UIImageView!
    @IBOutlet weak var ivClose: UIImageView!
    @IBOutlet weak var lblCurrentViewers: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    
    var stream:Stream! // Init by AthleteStreamsVC or UpcomingStreamsVC
    
    var bambuserPlayer: BambuserPlayer
    
//    var seekerTimer: Timer
   
    var isPausedByUser:Bool = false // Used to detect whether the play is paused or stopped
    
    @IBOutlet weak var viewDots: UIView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnUnfollow: UIButton!
    @IBOutlet weak var indicatorFollow: UIActivityIndicatorView!
    var following:[String:String]?
    
    
    
    required init?(coder aDecoder: NSCoder) {
        bambuserPlayer = BambuserPlayer()
//        seekerTimer = Timer()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bambuserPlayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        bambuserPlayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bambuserPlayer.delegate = self
        bambuserPlayer.applicationId = Iris.appId
        // This is a sample video; you can get a similarly signed resource URI for your broadcasts via the
        // Iris Metadata API.
        bambuserPlayer.playVideo(self.stream.resourceUri)
        self.view.addSubview(bambuserPlayer)
        
        self.setupUI()
    }
    func setupUI(){
        btnPlay.isHidden = true
        self.view.bringSubview(toFront: self.btnPlay)
        
        btnPause.isHidden = true
        self.view.bringSubview(toFront: self.btnPause)        
        
        self.view.bringSubview(toFront: self.btnClose)
        self.view.bringSubview(toFront: self.lblCurrentViewers)
        self.view.bringSubview(toFront: self.ivUsers)
        self.view.bringSubview(toFront: self.ivClose)
        self.view.bringSubview(toFront: self.viewDots)
        self.viewDots.layer.cornerRadius = 4.0
        self.view.bringSubview(toFront: self.viewAlert)
        self.viewAlert.isHidden = true
        self.viewAlert.layer.cornerRadius = 4.0
        self.ivPhoto.layer.cornerRadius = 24.0
        self.lblName.text = self.stream.creatorName
        self.lblName.adjustsFontSizeToFitWidth = true
        if self.stream.creatorImageURL != ""{
            let url = URL(string: self.stream.creatorImageURL)
            self.ivPhoto.kf.setImage(with: url)
        }
        
        //---- Setup UI according to the stream type: live or archived
        if self.stream.type == "live" || self.stream.type == "upcoming"{
            self.btnPlay.isHidden = true
            self.btnPause.isHidden = true
            self.lblCurrentViewers.text = "\(self.stream.currentViewers)"
        }else{
            self.btnPlay.isHidden = true
            self.btnPause.isHidden = false
            self.lblCurrentViewers.text = "\(self.stream.totalViewers)"
        }
        //----------------------------------
        
        //----- Show follow or unfollow button -----
        self.indicatorFollow.isHidden = true
        let myUserId = UserDefaults.standard.string(forKey: "userId")
        if self.stream.creatorId == myUserId{ // Don't follow myself
            self.btnFollow.isHidden = true
            self.btnUnfollow.isHidden = true
        }else{
            self.following = UserDefaults.standard.object(forKey: "following") as? [String : String]
            if self.following != nil && self.following?[self.stream.creatorId] != nil{ // Following already
                self.btnFollow.isHidden = true
                self.btnUnfollow.isHidden = false
            }else{ // Not following yet
                self.btnFollow.isHidden = false
                self.btnUnfollow.isHidden = true
            }
        }
        //-------------------------------------------
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    
    func updateSlider() {
        
    }
    
    func videoLoadFail() {
        NSLog("videoLoadFail called")
    }
    
    func playbackCompleted(){
        if self.stream.type != "archived"{
            // Live stream stopped.
            print(">>>Live stream finished")
            showAlert(title: nil, message: "The stream finished!", controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                self.dismiss(animated: true, completion: nil)
            }, cancelAction: nil)
            return
        }
    }
    
    func playbackStarted() {
        NSLog("playbackStarted called")
        if (!bambuserPlayer.live) {
            btnPause.isHidden = false
        }
        btnPlay.isHidden = true
//        seekerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlayerViewController.updateSlider), userInfo: nil, repeats: true)
    }
    
    func playbackPaused() {
        
        print(">>>playbackPaused called")
//        seekerTimer.invalidate()
        btnPause.isHidden = true
        btnPlay.isHidden = false
    }
   
//    func playbackStopped(){
//        print(">>>playbackStopped")
////        seekerTimer.invalidate()
//        btnPause.isHidden = false
//        btnPlay.isHidden = true
//    }
    
    func currentViewerCountUpdated(_ viewers: Int32) {
        if self.stream.type == "live"{
            lblCurrentViewers.text = "\(viewers)"
            self.stream.currentViewers = Int(viewers)
            self.updateCurrentViewers(stream: self.stream)
        }
    }
    func updateCurrentViewers(stream:Stream){
        FirebaseUtil.shared.updateCurrentViewers(stream: stream) { (error) in
            if error != nil{
                // Update failed, retry
                self.updateCurrentViewers(stream: stream)
            }
        }
    }
    func updateTotalViewers(stream:Stream){
        FirebaseUtil.shared.updateTotalViewers(stream: stream) { (error) in
            if error != nil{
                // Update failed, retry
                self.updateTotalViewers(stream: stream)
            }
        }
    }
    
    func totalViewerCountUpdated(_ viewers: Int32) {
        if self.stream.type == "archived"{
            lblCurrentViewers.text = "\(viewers)"
            self.stream.totalViewers = Int(viewers)
            self.updateTotalViewers(stream: self.stream)
        }
    }
    
    // MARK: - Button Actions
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnPauseTapped(_ sender: Any) {
        bambuserPlayer.pauseVideo()
        self.isPausedByUser = true
    }

    @IBAction func btnPlayTapped(_ sender: Any) {
        if bambuserPlayer.status == kBambuserPlayerStatePaused {
            if self.isPausedByUser == false { // The play is stopped, now replay from the begining
                bambuserPlayer.seek(to: 0)
            }
            
            bambuserPlayer.playVideo()
        }
        self.isPausedByUser = false
    }
    
    @IBAction func btnDotsTapped(_ sender: UIButton) {
        self.viewAlert.isHidden = false
        UIView.animate(withDuration: 0.1,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.viewAlert.center.y -= 149
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    
    @IBAction func btnXTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.viewAlert.center.y += 149
                        self.viewAlert.isHidden = true
        }, completion: { (finished) -> Void in
            // ....
        })
    }
    
    @IBAction func btnFollowTapped(_ sender: UIButton) {
        self.btnFollow.isHidden = true
        self.indicatorFollow.isHidden = false
        self.indicatorFollow.startAnimating()
        FirebaseUtil.shared.followUser(userId: self.stream.creatorId) { (error) in
            if error != nil{
                print(">>>Failed to follow the user. Error:\(String(describing: error?.localizedDescription))")
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnUnfollow.isHidden = false
                
                // Save to UserDefaults
                if self.following == nil{
                    self.following = [:]
                }
                self.following?[self.stream.creatorId] = self.stream.creatorId
                UserDefaults.standard.set(self.following, forKey: "following")
                
                // Send a push notification to the creator
                let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                let message = "\(userName) is following you!"
                self.sendNotification(message: message)
            }
        }
    }
    @IBAction func btnUnfollowTapped(_ sender: UIButton) {
        self.btnUnfollow.isHidden = true
        self.indicatorFollow.isHidden = false
        self.indicatorFollow.startAnimating()
        FirebaseUtil.shared.unfollowUser(userId: self.stream.creatorId) { (error) in
            if error != nil{
                print(">>>Failed to unfollow the user. Error:\(String(describing: error?.localizedDescription))")
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnUnfollow.isHidden = false
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.indicatorFollow.stopAnimating()
                self.indicatorFollow.isHidden = true
                self.btnFollow.isHidden = false
                
                // Save to UserDefaults
                if self.following == nil{
                    return
                }
                self.following?[self.stream.creatorId] = nil
                UserDefaults.standard.set(self.following, forKey: "following")
                
                // Send a push notification to the creator
                let userName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
                let message = "Oops! \(userName) unfollowed you!"
                self.sendNotification(message: message)
            }
        }
    }
    
    
    @IBAction func btnShareStreamTapped(_ sender: UIButton) {
    }
    @IBAction func btnReportStreamTapped(_ sender: UIButton) {
    }
    
    
    // MARK: - OneSignal
    func sendNotification(message:String){
        // Get the info of the user whom I'm following/unfollowing
        FirebaseUtil.shared.getUser(userId: self.stream.creatorId) { (user, error) in
            if error != nil{
                print(">>>Failed to get the creator info")
            }else{
                // If the user whom I'm following/unfollowing, doesn't want the push notifications, we don't send the notification
                if user.isSomeoneFollows == false {
                    return
                }
                
                OneSignalUtil.shared.sendNotification(date: Date(), userIds: [user.oneSignalUserId], message: message, heading: nil)
            }
        }
        
    }
    
}
