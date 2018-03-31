//
//  Course.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Foundation

struct Course: Equatable {

    var hasFollowed = false
    
    let school: String
    let courseId: String
    let description: String
    let name: String
    let number: String
    let postsCount: Int
    
    init(school: String, courseId: String, dictionary: [String: Any]) {
        self.school = school
        self.courseId = courseId
        self.description = dictionary["description"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.number = dictionary["number"] as? String ?? ""
        self.postsCount = dictionary["postsCount"] as? Int ?? 0
    }
    
    static func ==(lhs: Course, rhs: Course) -> Bool {//CourseControllerCell, handleTapButton
        return lhs.courseId == rhs.courseId
    }
    
}



