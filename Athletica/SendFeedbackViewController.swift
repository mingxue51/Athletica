//
//  SendFeedbackViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/24/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class SendFeedbackViewController: UIViewController {

    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var indicatorReport: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    func setupUI(){
        self.indicatorReport.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Button actions
    
    @IBAction func btnReportTapped(_ sender: Any) {
        if self.textView.text.isEmpty{
            showAlert(title: nil, message: "Please fill in your feedback.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        let text = trimmedStringFromString(string: self.textView.text)
        self.btnReport.isHidden = true
        self.indicatorReport.isHidden = false
        self.indicatorReport.startAnimating()
        
        let myId = UserDefaults.standard.string(forKey: "userId")!
        let myEmail = UserDefaults.standard.string(forKey: "email")!
        let myName = UserDefaults.standard.string(forKey: "firstName")! + " " +  UserDefaults.standard.string(forKey: "lastName")!
        let myType = UserDefaults.standard.string(forKey: "userType")!
        Network.sendFeedback(text:text, reporterId:myId, reporterName: myName, reporterEmail: myEmail, reporterType: myType, completion: { (dic) in
            
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
    
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        //        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

}
