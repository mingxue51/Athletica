//
//  ImageUtil.swift
//  Athletica
//
//  Created by SilverStar on 8/18/17.
//  Copyright © 2017 ClearAppDevelopment. All rights reserved.
//

import Foundation

class ImageUtil {
    
    static let shared = ImageUtil()

    // Resize and compress Image, default compressionQuality is 0.5, and target size is 375x667
    // Called from AtheleteEditProfileVC, CoachEditProfileVC, ChatVC, and LiveStreamVC
    func resizeImage(image: UIImage, compressionQuality:CGFloat = 0.5, targetSize: CGSize = CGSize(width: 375, height: 667) ) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImageData:Data = UIImageJPEGRepresentation(newImage!, compressionQuality)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: newImageData)!
    }


}
