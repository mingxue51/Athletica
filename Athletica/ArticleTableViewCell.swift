//
//  ArticleTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 7/1/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnShareTapped(_ sender: Any) {
    }
    

}
