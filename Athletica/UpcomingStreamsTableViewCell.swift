//
//  UpcomingStreamsTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 7/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit
import MarqueeLabel


class UpcomingStreamsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lblTitle: MarqueeLabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTime: MarqueeLabel!
    @IBOutlet weak var lblName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblTitle.type = .continuous
        lblTitle.scrollDuration = 10.0
        lblTitle.animationCurve = .easeInOut
        lblTitle.fadeLength = 10.0
//        lblTitle.leadingBuffer = 30.0
//        lblTitle.trailingBuffer = 20.0
        
        lblTime.type = .continuous
        lblTime.scrollDuration = 10.0
        lblTime.animationCurve = .easeInOut
        lblTime.fadeLength = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
