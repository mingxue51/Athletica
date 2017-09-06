//
//  InviteCoachesTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 7/27/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class InviteCoachesTableViewCell: UITableViewCell {

    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var lblCoachName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
