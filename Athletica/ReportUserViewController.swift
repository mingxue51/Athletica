//
//  ReportUserViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/22/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ReportUserViewController: UIViewController {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var indicatorReport: UIActivityIndicatorView!
   
    // Inited by ChatContainerVC, ViewAthleteVC, ViewCoachVC, ViewFanVC, and ViewProVC
    var userId:String!
    var userName:String!
    var photoURL:String!
    var userType:String!
    ///
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    func setupUI(){
        self.ivPhoto.layer.cornerRadius = 23.0
        if self.photoURL != ""{
            let url = URL(string:self.photoURL)
            self.ivPhoto.kf.setImage(with: url)
            self.ivPhoto.kf.indicatorType = .activity
        }
        
        self.lblUserName.text = self.userName
        self.lblUserType.text = self.userType
        
        self.indicatorReport.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Button actions
    
    @IBAction func btnReportTapped(_ sender: Any) {
        if self.textView.text.isEmpty{
            showAlert(title: nil, message: "Please fill in why the user is reported.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        let text = trimmedStringFromString(string: self.textView.text)
        self.btnReport.isHidden = true
        self.indicatorReport.isHidden = false
        self.indicatorReport.startAnimating()
        
        // Get user email first
        FirebaseUtil.shared.getUserEmail(userId: self.userId) { (userEmail, error) in
            
            if error != nil{
                self.indicatorReport.stopAnimating()
                self.indicatorReport.isHidden = true
                
                
                print(">>>Failed to get email. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                
                let myId = UserDefaults.standard.string(forKey: "userId")!
                let myEmail = UserDefaults.standard.string(forKey: "email")!
                let myName = UserDefaults.standard.string(forKey: "firstName")! + " " +  UserDefaults.standard.string(forKey: "lastName")!
                let myType = UserDefaults.standard.string(forKey: "userType")!
                Network.reportUser(userId: self.userId, userName: self.userName, userEmail: userEmail, userType: self.userType, text:text, reporterId:myId, reporterName: myName, reporterEmail: myEmail, reporterType: myType, completion: { (dic) in
                    
                    self.indicatorReport.stopAnimating()
                    self.indicatorReport.isHidden = true
                    
                    if dic != nil {
                        if dic!["success"] as! Int == 1{
                            showAlert(title: nil, message: dic!["message"] as! String, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
//                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true, completion: nil)
                                
                            }, cancelAction: nil)
                        }else{
                            showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                                self.btnReport.isHidden = false
                            }, cancelAction: nil)
                        }
                    }else{
                        showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: {
                            self.btnReport.isHidden = false
                        }, cancelAction: nil)
                    }
                    
                })
            }
        }
    }
   
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }


}
