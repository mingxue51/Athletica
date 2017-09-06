//
//  AthleteArticleViewController.swift
//  Athletica
//
//  Created by SilverStar on 7/2/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AthleteArticleViewController: UIViewController, UIWebViewDelegate {

    var link:String!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.webView.loadRequest(URLRequest(url: URL(string: link)!))
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
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnShareTapped(_ sender: Any) {
        
        let objectsToShare = [self.link]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.view
        
        
        self.present(activityVC, animated: true, completion: nil)
    }

    // WebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}

