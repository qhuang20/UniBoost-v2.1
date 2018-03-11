//
//  Post.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

struct Post {
    
    let user: User
    
    let postId: String
    let title: String
    let type: String
    var thumbnailImageUrl: String?
    
    init(user: User, postId: String, dictionary: [String: Any]) {
        self.user = user
        self.postId = postId
        self.title = dictionary["title"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.thumbnailImageUrl = dictionary["thumbnailImageUrl"] as? String
    }
    
}
