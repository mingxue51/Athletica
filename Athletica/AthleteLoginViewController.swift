//
//  AthleteLoginViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import OneSignal

class AthleteLoginViewController: BaseViewController {
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    
    @IBOutlet weak var svInput: UIStackView!
    
    var tfEmail:MyFloatingLabelTextField!
    var tfPassword:MyFloatingLabelTextField!

    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    
    func setupUI(){
        
       if tfEmail != nil {
            tfEmail.removeFromSuperview()
        }
        if tfPassword != nil {
            tfPassword.removeFromSuperview()
        }
                
        tfEmail = MyFloatingLabelTextField(frame: self.viewEmail.frame.insetBy(dx: 3, dy: 0))
        tfEmail.placeholder = "EMAIL"
        tfEmail.title = "EMAIL"
        tfEmail.keyboardType = .emailAddress
        self.svInput.addSubview(tfEmail)
        
        
        tfPassword = MyFloatingLabelTextField(frame: self.viewPassword.frame.insetBy(dx: 3, dy: 0))
        tfPassword.placeholder = "PASSWORD"
        tfPassword.title = "PASSWORD"
        tfPassword.isSecureTextEntry = true
        self.svInput.addSubview(tfPassword)
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Button actions
    @IBAction func btnWelcomeTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            
            //---- Test
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(ok)
//            self.present(alert, animated: true, completion: nil)
            //
        } else {
            login()
        }
    }
    func login(){
        if Reachability.isConnectedToNetwork(){
            
            self.startAnimating()
            let email = self.tfEmail.text!
            let password = self.tfPassword.text!
            Auth.auth().signIn(withEmail: email, password: password) { (firebaseUser, error) in
                
                if error == nil {
                    
                    // Read userInfo from Firebase Database and save to UserDefaults
                    let uid = firebaseUser?.uid
                    let userRef = Database.database().reference().child("users").child(uid!)
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        
                        let dicUser = snapshot.value as? [String:Any]
                        let user = User()
                        user.initWithDic(dic: dicUser!)
                        user.saveToUserDefaults()
                        print(">>>Firebase Login success. UserType is \(user.userType). FirstName is \(user.firstName)")
                        
                        /// If a coach, check 'verified', and call coachLogin if 'state' != 'verified'
                        // Otherwise go to NewsVC
                        if user.userType == UserType.coach.rawValue && user.state != "verified"{
                            Network.coachLogin(email: email, password: password, completion: { (dic) in
                                
                                if dic != nil {
                                    if dic!["success"] as! Int == 1{ // Verified
                                        user.state = "verified"
                                        UserDefaults.standard.setValue(user.state, forKey: "state")
                                        userRef.child("state").setValue(user.state, withCompletionBlock: { (error, ref) in
                                            self.stopAnimating()
                                            if error == nil{
                                                // Login success
                                                // Set flag in UserDefaults for later use
                                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                                
                                                self.updateOneSignalUserId()
                                                UserDefaults.standard.setValue("yes", forKey: "userInfoSaved")
                                                goToVC(name: "NavViewController", fromVC: self, animated: true)
                                            }else{
                                                UserDefaults.standard.setValue("no", forKey: "userInfoSaved")
                                                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                                            }
                                        })
                                        
                                    }else{
                                        self.stopAnimating()
                                        showAlert(title: nil, message: dic!["message"] as! String, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                                    }
                                }else{
                                    self.stopAnimating()
                                    showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                                }
                            })
                        }else{
                            // Login success
                            // Set flag in UserDefaults for later use
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            
                            self.stopAnimating()
                            self.updateOneSignalUserId()
                            goToVC(name: "NavViewController", fromVC: self, animated: true)
                        }

                    }, withCancel: { (error) in
                        print(">>>Failed to get UserInfo from Firebase DB. Error: \(error.localizedDescription)")
                        showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                    })
                    
                    
                    
                } else {
                    
                    self.stopAnimating()
                    
                    showAlert(title: nil, message: (error?.localizedDescription)!, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                }
            }
            
        }else{
            showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        }
    }
    func isEmptyFields()->String{
        
        var result:String = ""
        if (self.tfEmail.text?.isEmpty)! {
            result = AlertMessage.emailEmpty
            return result
        }
        if isValidEmail(testStr: (self.tfEmail.text)!) == false{
            result = AlertMessage.emailInvalid
            return result
        }
        if (self.tfPassword.text?.isEmpty)! {
            result = AlertMessage.passwordEmpty
            return result
        }
        return result
    }
    
    @IBAction func btnSignupTapped(_ sender: Any) {
        goToVC(name: "ChooseProfileViewController", fromVC: self, animated: true)
    }

    @IBAction func btnForgotTapped(_ sender: Any) {
        goToVC(name: "AthleleForgotPasswordViewController", fromVC: self, animated: true)
    }
    
    func updateOneSignalUserId(){
        // Upload OneSignal userId to Firebase DB
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        guard let oneSignalUserId = status.subscriptionStatus.userId else{return}
        FirebaseUtil.shared.uploadOneSignalUserId(userId: oneSignalUserId) { (error) in
            if error != nil{
                print(">>>Failed to upload OneSignal userId")
            }else{
                print(">>>Success to upload OneSignal userId")
            }
        }
    }
}
