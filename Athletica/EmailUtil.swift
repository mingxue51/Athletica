//
//  EmailUtil.swift
//  Athletica
//
//  Created by SilverStar on 8/22/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation
import MessageUI

class EmailUtil {
    static let shared = EmailUtil()
    
    // Open email with header "Report User"
    func reportUser(vc:UIViewController){
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = vc as? MFMailComposeViewControllerDelegate
        // Configure the fields of the interface.
        composeVC.setToRecipients(["davidroman0203@gmail.com"])
        composeVC.setSubject("Report User")
        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
        // Present the view controller modally.
        vc.present(composeVC, animated: true, completion: nil)
    }
}
