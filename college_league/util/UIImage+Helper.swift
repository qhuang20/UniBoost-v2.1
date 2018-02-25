//
//  UIImage+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-24.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UIImage{
    
    func resizeImageWith(ratio: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}
