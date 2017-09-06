//
//  OnboardViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/23/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import SwiftyOnboard

class OnboardViewController: UIViewController {
    
    var appDelegate:AppDelegate?

    
    
    @IBOutlet weak var swiftyOnboard: SwiftyOnboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftyOnboard.style = .light
        swiftyOnboard.delegate = self
        swiftyOnboard.dataSource = self
        swiftyOnboard.backgroundColor = UIColor(red: 46/256, green: 46/256, blue: 76/256, alpha: 1)
    }
    
    func handleSkip(sender:UIButton) {
        let index = sender.tag
        if index == 3{
            // Get started tapped
//            self.appDelegate?.setInitialVC()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            self.present(initialViewController, animated: true, completion: nil)
        }else{ // Skip tapped
            swiftyOnboard?.goToPage(index: 3, animated: true)
        }
    }
    
//    func handleContinue(sender: UIButton) {
//        let index = sender.tag
//        swiftyOnboard?.goToPage(index: index + 1, animated: true)
//    }
}

extension OnboardViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 4
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as? CustomPage
        
        if index == 0 {
            //On the first page, change the text in the labels to say the following:
            view?.titleLabel.text = "EXPLORE"
            view?.subTitleLabel.text = "View streams from other\nwomen and girls involved in\nsports from around the world."
            view?.image.image = UIImage(named: "btnExplore")
            view?.ivBg.image = UIImage(named:"bgTutorial1")
        } else if index == 1 {
            //On the second page, change the text in the labels to say the following:
            view?.titleLabel.text = "STAY UPDATED"
            view?.subTitleLabel.text = "Get the lastest news on the\nawesome things women and\ngirls are doing in sports."
            view?.image.image = UIImage(named: "btnStay")
            view?.ivBg.image = UIImage(named:"bgTutorial2")
        } else if index == 2 {
            //On the second page, change the text in the labels to say the following:
            view?.titleLabel.text = "KEEP IN TOUCH"
            view?.subTitleLabel.text = "Easily network and message\nanyone in our Athletica circle."
            view?.image.image = UIImage(named: "btnKeep")
            view?.ivBg.image = UIImage(named:"bgTutorial3")
        } else {
            //On the thrid page, change the text in the labels to say the following:
            view?.titleLabel.text = "SHOW OFF"
            view?.subTitleLabel.text = "Host your own live stream\nanytime, anywhere.\n\nNot ready to stream right now?\nSchedule one for later!"
            view?.image.image = UIImage(named: "btnShow")
            view?.ivBg.image = UIImage(named:"bgTutorial4")
        }
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
        overlay?.btnSkip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
        let currentPage = round(position)
        overlay.contentControl.currentPage = Int(currentPage)
        overlay.btnSkip.tag = Int(position)
        
        if currentPage == 3.0 {
            
            overlay.btnSkip.setImage(UIImage(named:"btnGet"), for: .normal)
            
        } else {
            overlay.btnSkip.setImage(UIImage(named:"btnSkip"), for: .normal)
            
        }
    }

}
