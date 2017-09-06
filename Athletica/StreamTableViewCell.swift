//
//  StreamTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 7/3/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class StreamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ivStream: UIImageView!
    @IBOutlet weak var ivLive: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblWatching: UILabel!
    @IBOutlet weak var viewFrame: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblUserName.adjustsFontSizeToFitWidth = true
        self.lblWatching.adjustsFontSizeToFitWidth = true
        // Initialization code
//        print(">>>viewFrame:")
//        dump(viewFrame.frame)
//        viewFrame.clipsToBounds = false
//        viewFrame.layer.shadowColor = UIColor.black.cgColor
//        viewFrame.layer.shadowOpacity = 1
//        viewFrame.layer.shadowOffset = CGSize.zero
//        viewFrame.layer.shadowRadius = 10
//        viewFrame.layer.shadowPath = UIBezierPath(roundedRect: viewFrame.bounds, cornerRadius: 10).cgPath
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
