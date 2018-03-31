//
//  User.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

struct User {

    var hasFollowed: Bool = false
    
    let uid: String
    let username: String
    let profileImageUrl: String
    var bio: String?
//    var school: String?
    
    var likes = 0
    var followers = 0
    var following = 0
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.followers = dictionary["followers"] as? Int ?? 0
        self.following = dictionary["following"] as? Int ?? 0
        if let bio = dictionary["bio"] as? String, bio.count > 0 {
            self.bio = bio
        }
//        if let school = dictionary["school"] as? String {
//            self.school = school
//        }
    }
    
}






