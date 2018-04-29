//
//  SearchSkillsControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SearchSkillsControllerCell: CourseSearchControllerCell {
    
    internal override func updateCoursesToDatabase() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        
        let ref = Database.database().reference().child("user_skills").child(currentLoggedInUserId).child(school)
        let values = [courseId: course?.hasFollowed == true ? 1 : 0]
        
        if course?.hasFollowed == true {
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to edited the course:", err)
                    return
                }
                print("Successfully added the skill: ", courseId)
            }
        } else {
            ref.child(courseId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to removed the course:", err)
                    return
                }
                print("Successfully removed the skill: ", courseId)
            }
        }
    }
    
}

