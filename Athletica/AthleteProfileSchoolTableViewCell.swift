//
//  AthleteProfileSchoolTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/4/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AthleteProfileSchoolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tfSchoolName: UITextField!
    @IBOutlet weak var tfZipcode: UITextField!
    @IBOutlet weak var tfGpa: UITextField!
    @IBOutlet weak var tfActScore: UITextField!
    @IBOutlet weak var tfSatScore: UITextField!
    @IBOutlet weak var tfApCredits: UITextField!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
