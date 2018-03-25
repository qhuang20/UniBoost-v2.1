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
    
    init(user: User, responseId: String, dictionary: [String: Any]) {
        self.user = user
        self.responseId = responseId
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
    
    static func ==(lhs: Response, rhs: Response) -> Bool {
        return lhs.responseId == rhs.responseId
    }
    
}
