//
//  ViewImageViewController.swift
//  Athletica
//
//  Created by SilverStar on 8/21/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage! // Init by ChatVC
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = self.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
