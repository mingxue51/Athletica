//
//  AthleleForgotPasswordViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/30/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AthleleForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var svInput: UIStackView!
    var tfEmail:MyFloatingLabelTextField!
    
    
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
        
        setupUI()
    }
    func setupUI(){
        
        tfEmail = MyFloatingLabelTextField(frame: self.viewEmail.frame.insetBy(dx: 3, dy: 0).offsetBy(dx: 0, dy: 10))
        tfEmail.placeholder = "EMAIL"
        tfEmail.title = "EMAIL"
        tfEmail.keyboardType = .emailAddress
        self.svInput.addSubview(tfEmail)
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

    @IBAction func btnLoginTapped(_ sender: UIButton) {
        goToVC(name: "AthleteLoginViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnRequestTapped(_ sender: UIButton) {
        let textField = self.tfEmail!
        
        if textField.text == "" {
            showAlert(title: nil, message: "Please enter your email.", controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            
        } else {
            if Reachability.isConnectedToNetwork(){
                self.startAnimating()
                Auth.auth().sendPasswordReset(withEmail: textField.text!, completion: { (error) in
                    self.stopAnimating()
                    var message = ""
                    
                    if error != nil {
                        message = (error?.localizedDescription)!
                    } else {
                        message = "Password reset email sent."
                    }
                    
                    showAlert(title: nil, message: message, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
                  
                })
            }else{
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }            
            
        }
    }
    
}
