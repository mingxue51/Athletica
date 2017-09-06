//
//  ProfileAboutTableViewCell.swift
//  Athletica
//
//  Created by SilverStar on 7/3/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

class ProfileAboutTableViewCell: UITableViewCell, ExpyTableViewHeaderCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivArrow: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeState(_ state: ExpyState, cellReuseStatus cellReuse: Bool) {
        
        switch state {
        case .willExpand:
            print("WILL EXPAND")
            hideSeparator()
            arrowUp(animated: !cellReuse)
            
        case .willCollapse:
            print("WILL COLLAPSE")
            arrowDown(animated: !cellReuse)
            
        case .didExpand:
            print("DID EXPAND")
            
        case .didCollapse:
            showSeparator()
            print("DID COLLAPSE")
        }
    }
    
    private func arrowUp(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) { [weak self] _ in
            self?.ivArrow.transform = CGAffineTransform(rotationAngle: (CGFloat.pi))
        }
    }
    
    private func arrowDown(animated: Bool) {
        UIView.animate(withDuration: (animated ? 0.3 : 0)) { [weak self] _ in
            self?.ivArrow.transform = CGAffineTransform(rotationAngle: 0)
        }
    }

}

extension UITableViewCell {
    
    func showSeparator() {
        DispatchQueue.main.async { [weak self] _ in
            self?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func hideSeparator() {
        DispatchQueue.main.async { [weak self] in
            self?.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
        }
    }
}
