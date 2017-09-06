//
//  NewMessageViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/20/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class NewMessageViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tvUsers: UITableView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
//    @IBOutlet weak var btnSend: UIButton!
//    @IBOutlet weak var tfInput: UITextField!
    
    
    var users:[User] = []
    var filteredUsers:[User] = []
    var peopleDownloaded:Bool = false
    var selectedUser:User? // Inited when the user chooses one user from the table of users
    
    @IBOutlet weak var tableViewBottomMargin: NSLayoutConstraint!
//    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Move buttonView up when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.tfName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        self.tfInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)


        self.indicator.startAnimating()
        self.indicator.isHidden = false
        self.tvUsers.tableFooterView = UIView()
        self.tvUsers.isHidden = false
        self.tvUsers.dataSource = self
        self.tvUsers.delegate = self
//        self.btnSend.isEnabled = false
        
        self.getUsers()
    }
    func getUsers(){
        FirebaseUtil.shared.getUsers(completion: { (users, error) in
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
            if error != nil{
                print(">>>Failed to get users. Error: \(String(describing: error))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.peopleDownloaded = true
                self.users = users
                self.filteredUsers = users
                
                self.tvUsers.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
//    @IBAction func btnSendTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
//        vc.receiverId = self.selectedUser?.userId
//        vc.receiverName = (self.selectedUser?.firstName)! + " " + (self.selectedUser?.lastName)!
//        vc.firstMessage = trimmedStringFromString(string:self.tfInput.text!)
//        self.navigationController?.pushViewController(vc, animated: false)
//    }
    

    //  MARK: - UITableViewDataSource and Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.filteredUsers.count;
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageTableViewCell") as! NewMessageTableViewCell
        let user = self.filteredUsers[indexPath.row]
        cell.textLabel?.text = user.firstName + " " + user.lastName
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = self.filteredUsers[indexPath.row]
        self.tfName.text = user.firstName + " " + user.lastName
        self.selectedUser = user
        
        // Go to ChatContainerVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatContainerViewController") as! ChatContainerViewController
        vc.receiverId = self.selectedUser?.userId
        vc.receiverName = (self.selectedUser?.firstName)! + " " + (self.selectedUser?.lastName)!
        vc.receiverPhotoURL = self.selectedUser?.imageURL
        vc.receiverUserType = self.selectedUser?.userType
        self.navigationController?.pushViewController(vc, animated: false)
    }

    // MARK: - UITextfieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tvUsers.isHidden = false
    }
    func textFieldDidChange(_ textField: UITextField) {
        let searchText = textField.text
        if textField == self.tfName{
            if searchText == ""{
                self.filteredUsers = self.users
                self.tvUsers.reloadData()
                return
            }
            
            self.filteredUsers.removeAll()
            for item in self.users {
                let name = item.firstName + " " + item.lastName
                if name.lowercased().contains((searchText?.lowercased())!){
                    self.filteredUsers.append(item)
                }
            }
            self.tvUsers.reloadData()
        }else{ // tfInput
//            if searchText != "" && self.selectedUser != nil{
//                self.btnSend.isEnabled = true
//            }else{
//                self.btnSend.isEnabled = false
//            }
        }
    }
    
    // MARK: - Move buttonView up when keyboard appears
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as?     NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.tableViewBottomMargin.constant = 0.0
                
//                // Disable Send button, set title to Send back
//                self.btnSend.isEnabled = false
//                self.btnSend.setTitle("Send", for:UIControlState())
                
            } else {
                self.tableViewBottomMargin.constant = endFrame?.size.height ?? 0.0
                
//                // Enable Send button, set title to Done at first
//                self.btnSend.isEnabled = true
//                self.btnSend.setTitle("Done", for:UIControlState())
                
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
 
}
