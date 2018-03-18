//
//  Comment.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

struct Comment {

    let user: User
    let toUser: User
    let text: String
    let creationDate: Date
    
    init(user: User, toUser: User, dictionary: [String: Any]) {
        self.user = user
        self.toUser = toUser
        self.text = dictionary["text"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}


