//
//  UIAttributtedString+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-09.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UITextView {
    
    func getParts() -> [Any] {
        var parts = [Any]()
        
        guard let attributedString = self.attributedText else { return parts }
        let range = NSMakeRange(0, attributedString.length)
        
        attributedString.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions.init(rawValue: 0)) { (dic, range, stop) in
            
            if dic.keys.contains(NSAttributedStringKey.attachment) {
                if let attachment = dic[NSAttributedStringKey.attachment] as? NSTextAttachment {
                    if let image: UIImage = attachment.image {
                        parts.append(image)
                        
                    } else if let image = attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) {
                        
                        parts.append(image)
                    }
                }
                
            } else {
                let string = attributedString.attributedSubstring(from: range).string
                let isValidString = !string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
                if isValidString {
                    let newString = string.trimmingCharacters(in: CharacterSet.newlines)
                    parts.append(newString)
                }
            }
        }

        return parts
    }
    
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

