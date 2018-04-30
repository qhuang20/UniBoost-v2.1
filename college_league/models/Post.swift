//
//  Post.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

struct Post {
    
    //just put them in datebase, no need to use them in UI
//    var courseId: String?//just for search
//    var school: String?//just for search
    
    var hasBookmarked: Bool = false
    var hasLiked: Bool = false
    
    var user: User
    let postId: String
    var course: Course?//changePostLikesCountForTrendingCell
    
    let title: String
    let type: String
    var thumbnailImageUrl: String?
    var thumbnailImageHeight: CGFloat?
    let creationDate: Date
    var likes: Int
    var response: Int
    
    init(user: User, postId: String, dictionary: [String: Any]) {
        self.user = user
        self.postId = postId
        
        self.title = dictionary["title"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.thumbnailImageUrl = dictionary["thumbnailImageUrl"] as? String
        self.thumbnailImageHeight = dictionary["thumbnailImageHeight"] as? CGFloat
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.likes = dictionary["likes"] as? Int ?? 0
        self.response = dictionary["response"] as? Int ?? 0
    }
    
}




