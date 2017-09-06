//
//  BaseViewController.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import TTGSnackbar

class BaseViewController: UIViewController, NVActivityIndicatorViewable {
    
    let indicatorSize = CGSize(width: 50, height: 50)
    let darkBlueColor = UIColor.init(red: 15/255.0, green: 110/255.0, blue: 190/255.0, alpha: 1.0)
    let lightGrayColor = UIColor.lightGray

    var snackbar: TTGSnackbar?
    
    

    func startAnimating(){
        startAnimating(indicatorSize, message: nil, type: NVActivityIndicatorType.ballSpinFadeLoader)
        
    }
    
    func showErrorSnackBar(message: String){
        DispatchQueue.main.async {
            self.snackbar?.backgroundColor = UIColor(red: 231/255.0, green: 30/255.0, blue: 98/255.0, alpha: 1.0)
            self.snackbar?.message = message
            self.snackbar!.show()
        }
    }
    func showSuccessSnackBar(message: String){
        DispatchQueue.main.async {
            self.snackbar?.backgroundColor = UIColor(red: 160/255.0, green: 216/255.0, blue: 203/255.0, alpha: 1.0)
            self.snackbar?.message = message
            self.snackbar!.show()
        }        
    }
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        self.snackbar = TTGSnackbar.init(message: "", duration: .middle)
        
        self.snackbar?.messageTextColor = UIColor.white
        self.snackbar!.dismissBlock = {
            (snackbar: TTGSnackbar) -> Void in
            
        }
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

}
