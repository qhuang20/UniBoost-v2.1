//
//  SetSkillsControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SetSkillsControllerCell: CourseControllerCell {
    
    @objc override func handleTapButton(button: UIButton) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        guard let indexPath = self.courseController?.collectionView?.indexPath(for: self) else { return }
        let i = self.courseController?.courses.index(of: self.course!)
        let ref = Database.database().reference().child("user_skills").child(currentLoggedInUserId).child(school)
        self.course?.hasFollowed = !self.course!.hasFollowed
        
        self.courseController?.filteredCourses[indexPath.item].hasFollowed = addButton.isSelected
        let values = [courseId: course?.hasFollowed == true ? 1 : 0]
        
        
        
        if addButton.isSelected {
            if i != nil { self.courseController?.courses[i!].hasFollowed = true }
            self.courseController?.followingCourses.append(self.course!)
            
        } else {
            if i != nil { self.courseController?.courses[i!].hasFollowed = false }
            
            if self.courseController?.viewOptionButton?.isSelected == true {
                self.courseController?.followingCourses.remove(at: indexPath.item)
                self.courseController?.filteredCourses.remove(at: indexPath.item)
                self.courseController?.collectionView?.reloadData()
            } else {
                if let j = self.courseController?.followingCourses.index(of: self.course!) {
                    self.courseController?.followingCourses.remove(at: j)
                }
            }
        }
        
        if course?.hasFollowed == true {
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to edited the course:", err)
                    return
                }
                print("Successfully edited the course: ", courseId)
            }
        } else {
            ref.child(courseId).removeValue { (err, ref) in
                if let err = err {
                    print("Failed to removed the course:", err)
                    return
                }
                print("Successfully removed the course: ", courseId)
            }
        }
    }
    
}






