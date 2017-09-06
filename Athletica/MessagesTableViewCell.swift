//
//  MessagesTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/19/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblKudo: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ivPhoto.layer.cornerRadius = 32.0
        self.lblName.adjustsFontSizeToFitWidth = true
        self.lblDate.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
