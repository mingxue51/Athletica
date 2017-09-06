//
//  ChatContainerViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/20/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import MessageUI

class ChatContainerViewController: BaseViewController {

    var receiverId:String!   // Inited by NewMessageVC or MessagesVC
    var receiverName:String! // Inited by NewMessageVC or MessagesVC
    var receiverPhotoURL:String! // Inited by NewMessageVC or MessagesVC
    var receiverUserType:String! // Inited by NewMessageVC or MessagesVC
    var receiverOneSignalUserId:String = "" // Inited by viewDidLoad method
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblReceiverName: UILabel!
    
    var childVC: ChatViewController?
    
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var indicatorBlock: UIActivityIndicatorView!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var indicatorMute: UIActivityIndicatorView!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var viewFilterBg: UIView!
    
    @IBOutlet weak var lblBlocked: UILabel! // Blocked by me
    @IBOutlet weak var lblBlockedByUser: UILabel!
    
    @IBOutlet weak var viewBlockedByUser: UIView!
    @IBOutlet weak var viewBlocked: UIView!
    
    
    
    var blockedUsers:[String:String]?
    let myUserId = UserDefaults.standard.string(forKey: "userId")!
    
    
    var isBlockedByUser:Bool? // Used in ChatVC to check if I'm blocked
    var isBlockedByMe:Bool? // Used in ChatVC to check if I blocked the user
    var isMutedByMe:Bool? // Used in ChatVC to check if notifications I get are muted
    var isMutedByUser:Bool? // Used in ChatVC to check if push notifications the user get are muted
    
    var appDelegate:AppDelegate? // Inited by AppDelegate
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getReceiverOneSignalUserId()
        self.setupUI()
        
    }
    func getReceiverOneSignalUserId(){
        FirebaseUtil.shared.getOneSignalUserId(userId: self.receiverId) { (oneSignalUserId, error) in
            if error != nil{
                print(">>>Failed to get oneSignalUserId. Error: \(String(describing: error?.localizedDescription)). Retrying in 3 seconds")
                self.perform(#selector(self.getReceiverOneSignalUserId), with: nil, afterDelay: 3)
            }else{
                self.receiverOneSignalUserId = oneSignalUserId
            }
        }
    }
    func setupUI(){
        self.lblReceiverName.text = self.receiverName
        
        self.viewFilter.isHidden = true
        self.viewFilter.layer.cornerRadius = 5
        self.viewFilterBg.isHidden = true
        self.lblBlocked.text = "\(self.receiverName!) is blocked. Unblock \(self.receiverName!) to continue the conversation."
        self.lblBlockedByUser.text = "\(self.receiverName!) blocked you."
        
        // Check if the user is blocked or not
        self.blockedUsers = UserDefaults.standard.object(forKey: "blockedUsers") as? [String:String]
        if self.blockedUsers != nil && self.blockedUsers?[receiverId] != nil {
            self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
            //self.viewContainer.isHidden = true
            self.viewBlocked.isHidden = false
            self.isBlockedByMe = true
            
        }else{
            self.btnBlock.setTitle("BLOCK USER", for: .normal)
            //self.viewContainer.isHidden = false
            self.viewBlocked.isHidden = true
            self.isBlockedByMe = false
        }
        self.indicatorBlock.isHidden = true
        
        // Check if the user muted notifications or not
        // TODO
        self.indicatorMute.isHidden = true
        
        // Check if the user blocked or blocks me
        self.viewBlockedByUser.isHidden = true
        self.startAnimating()
        FirebaseUtil.shared.observeIfBlockedByUser(userId: self.receiverId) { (dbHandle, isBlocked, error) in
            self.dbHandle = dbHandle
            
            if error != nil{
                self.stopAnimating()
                print(">>>Failed to observe if blocked. Error:\(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                    self.navigationController?.popViewController(animated: true)
                }, cancelAction: nil)
            }else{
                self.isBlockedByUser = isBlocked
                if isBlocked == true{
                    self.viewBlockedByUser.isHidden = false
                }else{
                    self.viewBlockedByUser.isHidden = true
                }
                
                // Check muteNotifications state for me and the user
                FirebaseUtil.shared.observeMuteNotifications(userId: self.receiverId, completion: { (dbHandle, isMutedByMe, isMutedByUser, error) in
                    self.muteHandle = dbHandle
                    
                    self.stopAnimating()
                    if error != nil{
                        print(">>>Failed to observe if muted. Error:\(String(describing: error?.localizedDescription))")
                        showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                            self.navigationController?.popViewController(animated: true)
                        }, cancelAction: nil)
                    }else{
                        self.isMutedByMe = isMutedByMe
                        self.isMutedByUser = isMutedByUser
                        if isMutedByMe == true{
                            self.btnMute.setTitle("UNMUTE NOTIFICATIONS", for: .normal)
                        }else{
                            self.btnMute.setTitle("MUTE NOTIFICATIONS", for: .normal)
                        }
                    }
                })
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        // Go to AthleteNewsVC if launched from a notification
        if self.appDelegate != nil{
            self.appDelegate?.setInitialVC()
            return
        }
        self.childVC?.isTyping = false
        self.childVC?.parentVC = nil
        self.childVC = nil
        self.viewContainer.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnMuteNotificationsTapped(_ sender: UIButton) {
        self.btnMute.isHidden = true
        self.indicatorMute.isHidden = false
        self.indicatorMute.startAnimating()
        
        if sender.titleLabel?.text == "MUTE NOTIFICATIONS"{
            // Mute
            FirebaseUtil.shared.setMuteNotifications(userId: self.receiverId, isMuted: true, completion: { (error) in
                self.indicatorMute.stopAnimating()
                self.indicatorMute.isHidden = true
                self.btnMute.isHidden = false
                if error != nil{
                    print(">>>Failed to mute notifications. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    
                    self.btnMute.setTitle("UNMUTE NOTIFICATIONS", for: .normal)
                    //self.viewContainer.isHidden = true
                    self.isMutedByMe = true
                    
                }
            })
        }else{
            // Unmute
            FirebaseUtil.shared.setMuteNotifications(userId: self.receiverId, isMuted: false, completion: { (error) in
                self.indicatorMute.stopAnimating()
                self.indicatorMute.isHidden = true
                self.btnMute.isHidden = false
                if error != nil{
                    print(">>>Failed to unmute notifications. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    
                    self.btnMute.setTitle("MUTE NOTIFICATIONS", for: .normal)
                    self.isMutedByMe = false
                    
                }
            })
        }
        
    }
    
    @IBAction func btnBlockTapped(_ sender: UIButton) {
        
        
        if sender.titleLabel?.text == "BLOCK USER"{
            // Block the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.blockUser(userId: self.receiverId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to block the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                   
                    self.btnBlock.setTitle("UNBLOCK USER", for: .normal)
                    //self.viewContainer.isHidden = true
                    self.viewBlocked.isHidden = false
                    self.isBlockedByMe = true
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        self.blockedUsers = [:]
                    }
                    self.blockedUsers?[self.receiverId] = self.receiverId
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                    
                    self.closeFilterView()
                }
            })
            
        }else{
            // Unblock the user
            self.btnBlock.isHidden = true
            self.indicatorBlock.isHidden = false
            self.indicatorBlock.startAnimating()
            FirebaseUtil.shared.unblockUser(userId: receiverId, completion: { (error) in
                self.indicatorBlock.stopAnimating()
                self.indicatorBlock.isHidden = true
                self.btnBlock.isHidden = false
                if error != nil{
                    print(">>>Failed to unblock the user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.btnBlock.setTitle("BLOCK USER", for: .normal)
                    //self.viewContainer.isHidden = false
                    self.viewBlocked.isHidden = true
                    self.isBlockedByMe = false
                    
                    // Save to UserDefaults
                    if self.blockedUsers == nil{
                        return
                    }
                    self.blockedUsers?[self.receiverId] = nil
                    UserDefaults.standard.set(self.blockedUsers, forKey: "blockedUsers")
                    
                    self.closeFilterView()
                }
            })
        }

    }
    
    @IBAction func btnReportTapped(_ sender: UIButton) {
        self.closeFilterView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportUserViewController") as! ReportUserViewController
        vc.userId = self.receiverId
        vc.userName = self.receiverName
        vc.userType = self.receiverUserType
        vc.photoURL = self.receiverPhotoURL
        self.present(vc, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "containerViewSegue" {
            childVC = segue.destination as? ChatViewController
            childVC!.parentVC = self
            
        }
    }
 
    //
    // Used to remove observer when this view controller is dismissed
    private var dbHandle: DatabaseHandle?
    private var muteHandle: DatabaseHandle?
    deinit{
        if let handle = dbHandle {
            let ref = Database.database().reference().child("users").child(receiverId).child("blockedUsers").child(myUserId)
            ref.removeObserver(withHandle: handle)
            print(">>>streamsRef observer removed")
        }
        if let handle = muteHandle {
            var channelId:String!
            if myUserId.compare(receiverId) == ComparisonResult.orderedAscending{
                channelId = myUserId + "/" + receiverId
            }else{
                channelId = receiverId + "/" + myUserId
            }
            let ref = Database.database().reference().child("channels").child(channelId).child("muteNotifications")
            ref.removeObserver(withHandle: handle)
            print(">>>mute observer removed")
        }
    }
 
}
