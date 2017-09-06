//
//  GiveKudosViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

protocol GiveKudosDelegate {
    func didGiveKudos()
}

class GiveKudosViewController: UIViewController {
    
    @IBOutlet weak var viewRelationship: UIView! // Teammate or so
    @IBOutlet weak var viewText: UIView!
    
    var tfRelationship:MyFloatingLabelTextField!
    var tfText:MyFloatingLabelTextField!
    
    var user:User! // Athlete to get kudos, init by ViewAthleteVC
    var delegate:GiveKudosDelegate! // Inited by ViewAthleteVC

    @IBOutlet weak var indicatorSubmit: UIActivityIndicatorView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.indicatorSubmit.isHidden = true
        self.lblTitle.text = "KUDOS FOR \(self.user.firstName.uppercased())"
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }
    
    func setupUI(){
        
        if tfRelationship != nil {
            tfRelationship.removeFromSuperview()
        }
        if tfText != nil {
            tfText.removeFromSuperview()
        }
        let userName = self.user.firstName
        tfRelationship = MyFloatingLabelTextField(frame: self.viewRelationship.frame.insetBy(dx: 3, dy: 0))
        tfRelationship.placeholder = "How do you know \(userName)?"
        tfRelationship.title = "How do you know \(userName)?"
        tfRelationship.keyboardType = .alphabet
        self.view.addSubview(tfRelationship)
        
        
        tfText = MyFloatingLabelTextField(frame: self.viewText.frame.insetBy(dx: 3, dy: 0))
        tfText.placeholder = "How is this athlete awesome?"
        tfText.title = "How is this athlete awesome?"
        tfText.keyboardType = .alphabet
        self.view.addSubview(tfText)
        
    }
    

    
    // MARK: - Button actions

    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        let message = self.isEmptyFields()
        if message != "" {
            showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
        } else {
            self.submit()
        }
    }
    func submit(){
        self.btnSubmit.isHidden = true
        self.indicatorSubmit.isHidden = false
        self.indicatorSubmit.startAnimating()
        
        let relationship = trimmedStringFromString(string: self.tfRelationship.text!)
        let text = trimmedStringFromString(string: self.tfText.text!)
        let senderId = UserDefaults.standard.string(forKey: "userId")!
        let senderName = UserDefaults.standard.string(forKey: "firstName")! + " " + UserDefaults.standard.string(forKey: "lastName")!
        let senderPhotoURL = UserDefaults.standard.string(forKey: "imageURL")!
        let receiverId = self.user.userId
        
        let kudo = Kudo()
        kudo.initWith(senderId: senderId, senderName: senderName, senderPhotoURL: senderPhotoURL, senderType: relationship, receiverId: receiverId, text: text)
        FirebaseUtil.shared.uploadKudo(kudo: kudo) { (error) in
            self.indicatorSubmit.stopAnimating()
            self.indicatorSubmit.isHidden = true
            self.btnSubmit.isHidden = false
            
            if error != nil{
                print(">>>Failed to upload kudo. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: "Failed to give kudo. Please check the Internet connection", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                return
            }
            // Refresh tvKudos in ViewAthleteVC
            self.delegate.didGiveKudos()
            
            // Send a notification
            let message = "\(senderName) sent you kudos"
            self.sendNotification(message:message)
            
            showAlert(title: "Kudos Sent!", message: "Your Kudos have been sent.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                self.navigationController?.popViewController(animated: true)
            }, cancelAction: nil)
        }
        
    }
    func isEmptyFields()->String{
        
        var result:String = ""
        if (self.tfRelationship.text?.isEmpty)! {
            result = "Please enter how you know \(self.user.firstName)"
            return result
        }
        if (self.tfText.text?.isEmpty)! {
            result = "Please enter how this athlete is awesome"
            return result
        }
        return result
    }
    func sendNotification(message:String){
        
        OneSignalUtil.shared.sendNotification(date: Date(), userIds: [self.user.oneSignalUserId], message: message, heading: nil)
    }
    
}
