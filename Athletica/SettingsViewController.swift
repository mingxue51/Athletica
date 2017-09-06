//
//  SettingsViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/19/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: BaseViewController {
    
    var user = User()
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var switchPrivate: UISwitch!
    @IBOutlet weak var switchSomeoneFollows: UISwitch!
    @IBOutlet weak var switchScheduledStream: UISwitch!
    @IBOutlet weak var switchFriendStarts: UISwitch!
    @IBOutlet weak var switchInvites: UISwitch!
    @IBOutlet weak var btnCancelSubscription: UIButton!

    @IBOutlet weak var viewInvites: UIView!
    @IBOutlet weak var viewCancel: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    // Show user info
    func setupUI(){
        self.user.initWithUserDefaults()
        
        // Hide invites view if the user is not a coach
        if self.user.userType != UserType.coach.rawValue {
            self.viewInvites.isHidden = true
        }
        // Hide cancel view if the user is not an athlete
        if self.user.userType != UserType.athlete.rawValue {
            self.viewCancel.isHidden = true
        }
        
        self.ivPhoto.layer.cornerRadius = 29.0
        let imageData = UserDefaults.standard.data(forKey: "imageData")
        if imageData != nil{
            self.ivPhoto.image = UIImage(data: imageData!)
        }else if self.user.imageURL != ""{
            let url = URL(string: self.user.imageURL)
            self.ivPhoto.kf.setImage(with: url)
        }
        
        self.lblName.text = self.user.firstName + " " + self.user.lastName
        
        self.switchPrivate.isOn = self.user.isPrivate
        self.switchPrivate.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        self.switchSomeoneFollows.isOn = self.user.isSomeoneFollows
        self.switchSomeoneFollows.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        self.switchScheduledStream.isOn = self.user.isScheduledStream
        self.switchScheduledStream.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        self.switchFriendStarts.isOn = self.user.isFriendStarts
        self.switchFriendStarts.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        self.switchInvites.isOn = self.user.isInvites
        self.switchInvites.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        
        // Show cancel view if the athlete is purchased
        if self.user.userType == UserType.athlete.rawValue{
            let timestamp = UserDefaults.standard.double(forKey: "expiryTimestamp")
            if isPurchasedAthlete(timestamp: timestamp){
                self.viewCancel.isHidden = false
            }else{
                self.viewCancel.isHidden = true
            }
        }
        
        
        
    }
    func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        
        switch mySwitch {
        case self.switchPrivate:
            self.startAnimating()
            FirebaseUtil.shared.setIsPrivate(userId: user.userId, isPrivate: value, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to set isPrivate on Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                    self.switchPrivate.setOn(!value, animated: true)
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: { 
                        
                    }, cancelAction: nil)
                }else{
                    self.user.isPrivate = value
                    UserDefaults.standard.set(value, forKey: "isPrivate")
                }
            })
        case self.switchSomeoneFollows:
            self.startAnimating()
            FirebaseUtil.shared.setIsSomeoneFollows(userId: user.userId, isSomeoneFollows: value, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to set isSomeoneFollows on Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                    self.switchSomeoneFollows.setOn(!value, animated: true)
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                        
                    }, cancelAction: nil)
                }else{
                    self.user.isSomeoneFollows = value
                    UserDefaults.standard.set(value, forKey: "isSomeoneFollows")
                }
            })
        case self.switchScheduledStream:
            self.startAnimating()
            FirebaseUtil.shared.setIsScheduledStream(userId: user.userId, isScheduledStream: value, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to set isScheduledStream on Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                    self.switchScheduledStream.setOn(!value, animated: true)
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                        
                    }, cancelAction: nil)
                }else{
                    self.user.isScheduledStream = value
                    UserDefaults.standard.set(value, forKey: "isScheduledStream")
                }
            })
        case self.switchFriendStarts:
            self.startAnimating()
            FirebaseUtil.shared.setIsFriendStarts(userId: user.userId, isFriendStarts: value, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to set isFriendStarts on Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                    self.switchFriendStarts.setOn(!value, animated: true)
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                        
                    }, cancelAction: nil)
                }else{
                    self.user.isFriendStarts = value
                    UserDefaults.standard.set(value, forKey: "isFriendStarts")
                }
            })
        case self.switchInvites:
            self.startAnimating()
            FirebaseUtil.shared.setIsInvites(userId: user.userId, isInvites: value, completion: { (error) in
                self.stopAnimating()
                if error != nil{
                    print(">>>Failed to set isFriendStarts on Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                    self.switchInvites.setOn(!value, animated: true)
                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                        
                    }, cancelAction: nil)
                }else{
                    self.user.isInvites = value
                    UserDefaults.standard.set(value, forKey: "isInvites")
                }
            })
        default:
            break
        }
    }
    /*
    func getUser(userId:String){
        self.startAnimating()
        FirebaseUtil.shared.getUser(userId: userId) { (user, error) in
            self.stopAnimating()
            if error != nil{
                print(">>>Failed to get user. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.user = user
                if self.user.imageURL != ""{
                    let url = URL(string: self.user.imageURL)
                    self.ivPhoto.kf.setImage(with: url)
                }
            }
        }
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Button actions
    @IBAction func btnChangePasswordTapped(_ sender: UIButton) {
        
        // Show an alert for the user to input the current email and password first
        let alertController = UIAlertController(title: "Enter Credentials", message: nil, preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: "Change", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            let thirdTextField = alertController.textFields![2] as UITextField
            
            // Change password
            let credential = EmailAuthProvider.credential(withEmail:firstTextField.text!, password: secondTextField.text!)
            self.startAnimating()
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                if let error = error {
                    self.stopAnimating()
                    // An error happened.
                    print(">>>Failed to reauthenticate. Error:(\(error.localizedDescription))")
                    showAlert(title: nil, message: "Failed to change the password. Please check the Internet connection", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                } else {
                    // User re-authenticated.
                    // Now update the password
                    Auth.auth().currentUser?.updatePassword(to: thirdTextField.text!, completion: { (error) in
                        self.stopAnimating()
                        if error != nil{
                            print(">>>Failed to change the password. Error: \(String(describing: error?.localizedDescription))")
                            showAlert(title: nil, message: "Failed to change password. Please check the Internet connection.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                        }else{
                            self.showSuccessSnackBar(message: "Password changed")
                        }
                    })
                    
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Current Email"
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func btnChangeEmailTapped(_ sender: UIButton) {
        
        // Show an alert for the user to input the current email and password first
        let alertController = UIAlertController(title: "Enter Credentials", message: nil, preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: "Change", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            let thirdTextField = alertController.textFields![2] as UITextField
            
            // Change email
            let credential = EmailAuthProvider.credential(withEmail:firstTextField.text!, password: secondTextField.text!)
            self.startAnimating()
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
                
                let email = thirdTextField.text!
                
                if let error = error {
                    // An error happened.
                    self.stopAnimating()
                    print(">>>Failed to reauthenticate. Error:(\(error.localizedDescription))")
                    showAlert(title: nil, message: "Failed to change the email. \(error.localizedDescription)", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                } else {
                    // User re-authenticated.
                    // Now update the password
                   Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                        self.stopAnimating()
                        if error != nil{
                            print(">>>Failed to change the email. Error: \(String(describing: error?.localizedDescription))")
                            showAlert(title: nil, message: "Failed to change the email. \(String(describing: error?.localizedDescription))", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                        }else{
                            
                            self.showSuccessSnackBar(message: "Email changed")
                            UserDefaults.standard.set(email, forKey: "email")
                            // Now update Firebase DB
                            self.updateEmailInFirebaseDB(email: email)
                            
                        }
                    })
                    
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Current Email"
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "New Email"
            textField.keyboardType = .emailAddress
        }
        
        alertController.addAction(changeAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func updateEmailInFirebaseDB(email:String){
        FirebaseUtil.shared.updateEmail(email: email, completion: { (error) in
            if error != nil{
                print(">>>Failed to change the email in Firebase DB. Error: \(String(describing: error?.localizedDescription))")
                self.updateEmailInFirebaseDB(email: email)
            }else{
                print(">>>Email changed in Firebase DB")
            }
        })
    }
    
    @IBAction func btnBlockedUsersTapped(_ sender: UIButton) {
        navigateToVC(name: "BlockedUsersViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnAuthorizedUsersTapped(_ sender: UIButton) {
        navigateToVC(name: "AuthorizedUsersViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnCancelSubscriptionTapped(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
    }
    
}
