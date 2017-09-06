//
//  MyFloatingLabelTextField.swift
//  Athletica
//
//  Created by SilverStar on 6/29/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class MyFloatingLabelTextField: SkyFloatingLabelTextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let lightGreyColor = UIColor(red: 200/255.0, green: 197/255.0, blue: 197/255.0, alpha: 1.0)
//        let darkGreyColor = UIColor(red: 52/255.0, green: 42/255.0, blue: 61/255.0, alpha: 1.0)
        let overcastBlueColor = UIColor(red: 80/255.0, green: 227/255.0, blue: 194/255.0, alpha: 1.0)
        
        self.tintColor = overcastBlueColor // the color of the blinking cursor
        self.textColor = lightGreyColor
        self.lineColor = lightGreyColor
        self.titleColor = overcastBlueColor
        self.selectedTitleColor = overcastBlueColor
        self.selectedLineColor = overcastBlueColor
        self.lineHeight = 1.0 // bottom line height in points
        self.selectedLineHeight = 2.0
        
        self.font = UIFont(name:"AvenirNext-Medium", size: 14.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
