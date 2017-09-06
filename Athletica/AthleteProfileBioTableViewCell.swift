//
//  AthleteProfileBioTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/4/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AthleteProfileBioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tfHeight: UITextField!
    @IBOutlet weak var tfWeight: UITextField!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfClassOf: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
