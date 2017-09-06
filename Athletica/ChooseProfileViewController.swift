//
//  ChooseProfileViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/30/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import JHTAlertController

class ChooseProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Orientation
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Button Actions
    @IBAction func btnAthleteTapped(_ sender: Any) {
        // Setting up an alert with a title and message
        let alertController = JHTAlertController(title: "", message: "ARE YOU A\nPROFESSIONAL ATHLETE?", preferredStyle: .alert)
        
        alertController.titleImage = UIImage(named: "athleteSignup")
        alertController.restrictTitleViewHeight = true
        let bgColor = UIColor(colorLiteralRed: 160/255.0, green: 216/255.0, blue: 203/255.0, alpha: 1.0)
        alertController.alertBackgroundColor = bgColor
        alertController.titleViewBackgroundColor = bgColor
        alertController.setAllButtonBackgroundColors(to: bgColor)
        alertController.messageFont = UIFont.boldSystemFont(ofSize: 18.0)
        
        
        // Create the action.
        let cancelAction = JHTAlertAction(title: "NO", style: .cancel){ _ in
            // Athlete
            // Go to AthleteSignupVC
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AthleteSignupViewController") as! AthleteSignupViewController
            vc.userType = UserType.athlete.rawValue
            self.present(vc, animated: true, completion: nil)
        }
        
        // Create an action with a completionl handler.
        let okAction = JHTAlertAction(title: "YES", style: .cancel) { _ in
            // Pro athlete
            // Go to AthleteSignupVC
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AthleteSignupViewController") as! AthleteSignupViewController
            vc.userType = UserType.proAthlete.rawValue
            self.present(vc, animated: true, completion: nil)
        }
        
        // Add the actions to the alert.
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Show the action
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnLoginTapped(_ sender: Any) {
        goToVC(name: "AthleteLoginViewController", fromVC: self, animated: true)
    }

    @IBAction func btnCoachTapped(_ sender: UIButton) {
        // Coach
        // Go to CoachSignupVC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CoachSignupViewController") as! CoachSignupViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnFanTapped(_ sender: UIButton) {
        // Fan
        // Go to AthleteSignupVC
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AthleteSignupViewController") as! AthleteSignupViewController
        vc.userType = UserType.fan.rawValue
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnTermsTapped(_ sender: UIButton) {
        // Go to TermsViewController
        goToVC(name: "TermsViewController", fromVC: self, animated: false)
    }
}
