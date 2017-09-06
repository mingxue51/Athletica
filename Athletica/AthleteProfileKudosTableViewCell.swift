//
//  AthleteProfileKudosTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/8/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class AthleteProfileKudosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSenderType: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btnTrashKudos: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.ivPhoto.layer.cornerRadius = 22.0
        self.ivPhoto.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
