//
//  Article.swift
//  Athletica
//
//  Created by SilverStar on 7/1/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import UIKit

// News article
class Article: NSObject {
    var title:String!
    var link:String!
    var text:String!
    
    init(title:String, link:String, text:String) {
        self.title = title
        self.link = link
        self.text = text
    }
}
