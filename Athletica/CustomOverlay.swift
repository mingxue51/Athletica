//
//  CustomOverlay.swift
//  SwiftyOnboardExample
//
//  Created by Jay on 3/27/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit
import SwiftyOnboard

class CustomOverlay: SwiftyOnboardOverlay {
    
    @IBOutlet weak var contentControl: UIPageControl!
    @IBOutlet weak var btnSkip: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentControl.transform = CGAffineTransform(scaleX: 2, y: 2)
       
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomOverlay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}
