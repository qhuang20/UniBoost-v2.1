//
//  ResponseMessage.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

struct ResponseMessage {
    
    var text: String?
    var imageUrl: String?
    var thumbnailUrl: String?
    var imageHeight: CGFloat?
    
    init(dictionary: [String: Any]) {
        text = dictionary["text"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        thumbnailUrl = dictionary["thumbnailUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? CGFloat
    }
    
}

