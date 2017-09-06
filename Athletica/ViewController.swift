//
//  ViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Actions
    @IBAction func btnSignupTapped(_ sender: Any) {
        goToVC(name: "ChooseProfileViewController", fromVC: self, animated: true)
    }
    
    @IBAction func btnLoginTapped(_ sender: Any) {
        goToVC(name: "AthleteLoginViewController", fromVC: self, animated: true)
    }

    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }   
    @IBAction func btnTermsTapped(_ sender: UIButton) {
        // Go to TermsViewController
        goToVC(name: "TermsViewController", fromVC: self, animated: false)
    }
    
}

