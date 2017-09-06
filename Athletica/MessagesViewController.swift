//
//  MessagesViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/19/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class MessagesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var users:[MessagingUser] = []
    var pendingKudos:[Kudo] = []
    
    @IBOutlet weak var tvFollowing: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show activity indicator while fetching streams
        self.tvFollowing.tableFooterView = UIView()
        self.tvFollowing.dataSource = self
        self.tvFollowing.delegate = self
        self.indicator.startAnimating()
        self.indicator.isHidden = false
        
        // Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tvFollowing.addSubview(refreshControl)
                
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getMessagingUsers()
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.getMessagingUsers()
    }
    func getMessagingUsers(){
        let userId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.getMessagingUsers(userId: userId) { (users, error) in
            if error != nil{
                print(">>>Failed to get messagingUsers. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.users = users
                self.getPendingKudos()
            }
        }
    }
    func getPendingKudos(){
        let userId = UserDefaults.standard.string(forKey: "userId")!
        FirebaseUtil.shared.getPendingKudosOnce(userId: userId) { (kudos, error) in
            if self.indicator.isHidden == false{
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
            }
            
            if error != nil{
                
                print(">>>Failed to get pending kudos. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.pendingKudos = kudos
                self.tvFollowing.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        navigateToVC(name: "NewMessageViewController", fromVC: self, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let user = self.users[indexPath.row]
            // Delete pendingUser from Firebase DB
            self.startAnimating()
            FirebaseUtil.shared.deleteMessagingUser(userId: user.userId, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print("Failed to delete the messaging user. Error: \(String(describing: error?.localizedDescription))")
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }else{
                    self.users.remove(at: indexPath.row)
//                    self.showSuccessSnackBar(message: "Deleted successfully!")
                    self.tvFollowing.reloadData()
                }
                
            })
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{ // MessageUser tapped
            let selectedUser = self.users[indexPath.row]
            // Go to ChatContainerVC
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
            vc.receiverId = selectedUser.userId
            vc.receiverName = selectedUser.userName
            vc.receiverPhotoURL = selectedUser.imageURL
            vc.receiverUserType = selectedUser.userType
            self.navigationController?.pushViewController(vc, animated: false)
//            self.present(vc, animated: true, completion: nil)
            
        }else{ // A pending kudo is tapped
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ApproveKudosViewController") as! ApproveKudosViewController
            vc.kudo = self.pendingKudos[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.users.count
        }else{
            return self.pendingKudos.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesTableViewCell", for: indexPath) as! MessagesTableViewCell
        
        var imageURL:String!
        var userName:String!
        var timestamp:Double!
        
        if indexPath.section == 0{
            let user = self.users[indexPath.row]
            imageURL = user.imageURL
            userName = user.userName
            timestamp = user.timestamp
            cell.lblKudo.isHidden = true
        }else{
            let kudo = self.pendingKudos[indexPath.row]
            imageURL = kudo.senderPhotoURL
            userName = kudo.senderName
            timestamp = kudo.timestamp
            cell.lblKudo.isHidden = false
        }
        
        
        cell.lblName.text = userName
        
        if imageURL != ""{
            let url = URL(string: imageURL)
            cell.ivPhoto.kf.setImage(with: url)
            cell.ivPhoto.kf.indicatorType = .activity
        }
        
        let strDate = dateStringWithTimestamp(timestamp: timestamp)
        cell.lblDate.text = strDate
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
