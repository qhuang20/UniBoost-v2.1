//
//  UIAttributtedString+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-09.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UITextView {
    
    func getImages() -> [UIImage] {
        var images = [UIImage]()
        
        guard let attributedString = self.attributedText else { return images }
        
        let range = NSMakeRange(0, attributedString.length)
        attributedString.enumerateAttribute(NSAttributedStringKey.attachment, in: range, options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (value, range, stop) in
            guard let attachment = value as? NSTextAttachment else { return }
            
            if let image = attachment.image {
                images.append(image)
                
            } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                
                images.append(image)
            }
        }
        
        return images
    }
    
}

