//
//  FollowingTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/9/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
