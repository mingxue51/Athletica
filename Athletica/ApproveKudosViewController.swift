//
//  ApproveKudosViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/20/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ApproveKudosViewController: BaseViewController {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblSenderName: UILabel!
    @IBOutlet weak var lblSenderRelationship: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btnApprove: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var indicatorApprove: UIActivityIndicatorView!
    @IBOutlet weak var indicatorReject: UIActivityIndicatorView!
    
    var kudo:Kudo! // Inited by MessagesVC

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    func setupUI(){
        self.ivPhoto.layer.cornerRadius = 23.0
        if self.kudo.senderPhotoURL != ""{
            let url = URL(string:self.kudo.senderPhotoURL)
            self.ivPhoto.kf.setImage(with: url)
            self.ivPhoto.kf.indicatorType = .activity
        }
        
        self.lblSenderName.text = self.kudo.senderName
        self.lblSenderRelationship.text = self.kudo.senderType
        self.lblText.text = self.kudo.text
        
        self.indicatorApprove.isHidden = true
        self.indicatorReject.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Button actions
    
    @IBAction func btnApproveTapped(_ sender: Any) {
        self.btnApprove.isHidden = true
        self.indicatorApprove.isHidden = false
        self.indicatorApprove.startAnimating()
        
        FirebaseUtil.shared.approveKudo(kudo: self.kudo) { (error) in
            self.indicatorApprove.stopAnimating()
            self.indicatorApprove.isHidden = true
            if error != nil{
                print(">>>Failed to approve kudo. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                self.showSuccessSnackBar(message: "Kudo approved!")
                let index = (self.navigationController?.viewControllers.count)!-3
                let athleteProfileVC = self.navigationController?.viewControllers[index]
                self.navigationController?.popToViewController(athleteProfileVC!, animated: true)
            }
        }
    }

 
    @IBAction func btnRejectTapped(_ sender: UIButton) {
        self.btnApprove.isHidden = true
        self.indicatorApprove.isHidden = false
        self.indicatorApprove.startAnimating()
        
        FirebaseUtil.shared.deleteMyKudo(kudoId: self.kudo.kudoId) { (error) in
            self.indicatorApprove.stopAnimating()
            self.indicatorApprove.isHidden = true
            if error != nil{
                print(">>>Failed to reject kudo. Error: \(String(describing: error?.localizedDescription))")
                showAlert(title: nil, message: AlertMessage.noInternet, controller: self, okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            }else{
                let index = (self.navigationController?.viewControllers.count)!-3
                let athleteProfileVC = self.navigationController?.viewControllers[index]
                self.navigationController?.popToViewController(athleteProfileVC!, animated: true)
            }
        }
    }
    // MARK: - Button actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
