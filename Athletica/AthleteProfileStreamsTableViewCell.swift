//
//  AthleteProfileStreamsTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 8/8/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import MarqueeLabel

class AthleteProfileStreamsTableViewCell: UITableViewCell {

    @IBOutlet weak var ivStream: UIImageView!
    @IBOutlet weak var btnTrash2: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnRadio: UIButton!
    @IBOutlet weak var lblTitle: MarqueeLabel!
    @IBOutlet weak var lblDate: MarqueeLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.type = .continuous
        lblTitle.scrollDuration = 10.0
        lblTitle.animationCurve = .easeInOut
        lblTitle.fadeLength = 10.0
        
        lblDate.type = .continuous
        lblDate.scrollDuration = 10.0
        lblDate.animationCurve = .easeInOut
        lblDate.fadeLength = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
