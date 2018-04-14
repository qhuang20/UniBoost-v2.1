//
//  Response.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

struct Response: Equatable {

    var hasLiked = false
    
    let user: User
    let responseId: String
    let creationDate: Date
    var likes: Int
    
    //for user profile response
    var post: Post?
    let postId: String
    
    init(user: User, responseId: String, dictionary: [String: Any]) {
        self.user = user
        self.responseId = responseId
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        self.likes = dictionary["likes"] as? Int ?? 0
        self.postId = dictionary["postId"] as? String ?? ""
    }
    
    static func ==(lhs: Response, rhs: Response) -> Bool {
        return lhs.responseId == rhs.responseId
    }
    
}
