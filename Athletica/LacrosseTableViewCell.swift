//
//  LacrosseTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/4/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class LacrosseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tfStat1: UITextField!
    @IBOutlet weak var tfStat2: UITextField!
    @IBOutlet weak var tfStat3: UITextField!
    @IBOutlet weak var tfStat4: UITextField!
    @IBOutlet weak var tfStat5: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}