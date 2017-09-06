//
//  AthleteSignupViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import OneSignal


class AthleteSignupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var svInput: UIStackView!
    @IBOutlet weak var viewFirstName: UIView!
    @IBOutlet weak var viewLastName: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var viewCategory: UIView!
    
    let myPickerData = [String](arrayLiteral: "Soccer", "Basketball", "Swimming", "Track & Field", "Tennis", "Softball", "Golf", "Volleyball", "Lacrosse", "Hockey", "Rowing", "Water Polo", "Gymnastics", "Skiiing", "Football")
    
    var tfFirstName:MyFloatingLabelTextField!
    var tfLastName:MyFloatingLabelTextField!
    var tfEmail:MyFloatingLabelTextField!
    var tfPassword:MyFloatingLabelTextField!
    var tfCategory:MyFloatingLabelTextField!
    
    var userType:String! // Initialized by ChooseProfileVC
    
    
    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupUI(){
        if tfFirstName != nil {
            tfFirstName.removeFromSuperview()
        }
        if tfLastName != nil {
            tfLastName.removeFromSuperview()
        }
        if tfEmail != nil {
            tfEmail.removeFromSuperview()
        }
        if tfPassword != nil {
            tfPassword.removeFromSuperview()
        }
        if tfCategory != nil {
            tfCategory.removeFromSuperview()
        }
        
        tfFirstName = MyFloatingLabelTextField(frame: self.viewFirstName.frame.insetBy(dx: 3, dy: 0))
        tfFirstName.placeholder = "FIRST NAME"
        tfFirstName.title = "FIRST NAME"
        tfFirstName.keyboardType = .namePhonePad
        svInput.addSubview(tfFirstName)
        
        
        tfLastName = MyFloatingLabelTextField(frame: self.viewLastName.frame.insetBy(dx: 3, dy: 0))
        tfLastName.placeholder = "LAST NAME"
        tfLastName.title = "LAST NAME"
        tfLastName.keyboardType = .namePhonePad
        svInput.addSubview(tfLastName)
        
        
        tfEmail = MyFloatingLabelTextField(frame: self.viewEmail.frame.insetBy(dx: 3, dy: 0))
        tfEmail.placeholder = "EMAIL"
        tfEmail.title = "EMAIL"
        tfEmail.keyboardType = .emailAddress
        svInput.addSubview(tfEmail)
        
        
        tfPassword = MyFloatingLabelTextField(frame: self.viewPassword.frame.insetBy(dx: 3, dy: 0))
        tfPassword.placeholder = "PASSWORD"
        tfPassword.title = "PASSWORD"
        tfPassword.isSecureTextEntry = true
        svInput.addSubview(tfPassword)
        
        
        tfCategory = MyFloatingLabelTextField(frame: self.viewCategory.frame.insetBy(dx: 3, dy: 0))
        tfCategory.placeholder = "SPORT CATEGORY"
        tfCategory.title = "SPORT CATEGORY"
        svInput.addSubview(tfCategory)
        
        let thePicker = UIPickerView()
        tfCategory.inputView = thePicker
        thePicker.delegate = self
        
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
    
    // MARK: UIPickerViewDataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfCategory.text = myPickerData[row]
    }
    
    // MARK: Button Actions
    
    @IBAction func btnTermsTapped(_ sender: UIButton) {
        // Go to TermsViewController
        goToVC(name: "TermsViewController", fromVC: self, animated: false)
    }
    
    @IBAction func btnGoTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            
        } else {
            
            self.signUp()
            
        }
    }
    
    @IBAction func btnLoginTapped(_ sender: Any) {
        goToVC(name: "AthleteLoginViewController", fromVC: self, animated: true)
    }

    func signUp(){
        if Reachability.isConnectedToNetwork(){
            
            self.startAnimating()
            
            let email = trimmedStringFromString(string: self.tfEmail.text!)
            let firstName = trimmedStringFromString(string: self.tfFirstName.text!)
            let lastName = trimmedStringFromString(string: self.tfLastName.text!)
            let category = self.tfCategory.text!
            let password = self.tfPassword.text!
            let state:String = "verified"
            
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let oneSignalUserId = status.subscriptionStatus.userId
            
            
            Auth.auth().createUser(withEmail: email, password: password) { (firebaseUser, error) in
                
                if error == nil {
                    // Create a User object
                    let user = User()
                    user.initWith(userId: (firebaseUser?.uid)!, userType: self.userType, firstName: firstName, lastName: lastName, category: category, email: email, imageURL: "", oneSignalUserId: oneSignalUserId!, state: state, isPrivate: false, isSomeoneFollows: false, isScheduledStream: true, isFriendStarts: true, isInvites: true, expiryTimestamp: 0)
                    
                    // Register user info to Firebase database
                    let userRef = Database.database().reference().child("users").child((firebaseUser?.uid)!)
                    let userDic = user.dictionary()
                    
                    
                    userRef.setValue(userDic, withCompletionBlock: { (error, ref) in
                        
                        user.saveToUserDefaults()
                        
                        self.stopAnimating()
                        
                        if error == nil{
                            // userType&userName is saved in Firebase Database
                            UserDefaults.standard.set("yes", forKey: "userInfoSaved")
                            UserDefaults.standard.synchronize()
                            
                        }else{
                            // userType&userName is NOT saved in Firebase Database
                            UserDefaults.standard.set("no", forKey: "userInfoSaved")
                            UserDefaults.standard.synchronize()
                        }
                        
                        // If a coach, go to CoachSignupViewController
                        // Otherwise go to NewsVC
                        if self.userType == UserType.coach.rawValue {
                            goToVC(name: "CoachSignupViewController", fromVC: self, animated: true)
                        }else{
                            // Signup success
                            // Set flag in UserDefaults for later use
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            goToVC(name: "NavViewController", fromVC: self, animated: true)
                        }
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
        if (self.tfFirstName.text?.isEmpty)! {
            result = AlertMessage.firstNameEmpty
            return result
        }
        if (self.tfLastName.text?.isEmpty)! {
            result = AlertMessage.lastNameEmpty
            return result
        }
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
        if (self.tfCategory.text?.isEmpty)! {
            result = AlertMessage.categoryEmpty
            return result
        }
        return result
    }
}
