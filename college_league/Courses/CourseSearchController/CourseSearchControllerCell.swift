//
//  CourseSearchControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class CourseSearchControllerCell: CourseControllerCell {
    
    var superCourseController: CourseController?
    
    @objc override func handleTapButton(button: UIButton) {
        self.course?.hasFollowed = !self.course!.hasFollowed
        guard let indexPath = self.courseController?.collectionView?.indexPath(for: self) else { return }
        self.courseController?.filteredCourses[indexPath.item].hasFollowed = addButton.isSelected
        let i = self.courseController?.courses.index(of: self.course!)
        if i != nil { self.courseController?.courses[i!].hasFollowed = addButton.isSelected }
        
        let superI = self.superCourseController?.courses.index(of: self.course!)
        if superI != nil { self.superCourseController?.courses[superI!].hasFollowed = addButton.isSelected }
        let superJ = self.superCourseController?.filteredCourses.index(of: self.course!)
        if superJ != nil {
            self.superCourseController?.filteredCourses[superJ!].hasFollowed = addButton.isSelected
        }
        
        
        
        if addButton.isSelected {
            self.superCourseController?.followingCourses.append(self.course!)
            
            if superCourseController?.viewOptionButton?.isSelected == true {
                self.superCourseController?.filteredCourses.append(self.course!)
            }
            
        } else {
            if self.superCourseController?.viewOptionButton?.isSelected == true {
                if let j = self.superCourseController?.followingCourses.index(of: self.course!) {
                    self.superCourseController?.followingCourses.remove(at: j)
                    self.superCourseController?.filteredCourses.remove(at: j)
                }
            } else {
                if let j = self.superCourseController?.followingCourses.index(of: self.course!) {
                    self.superCourseController?.followingCourses.remove(at: j)
                }
            }
        }
        
        superCourseController?.collectionView?.reloadData()
        
        updateCoursesToDatabase()
    }
    
    internal func updateCoursesToDatabase() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        let values = [courseId: course?.hasFollowed == true ? 1 : 0]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to edited the course:", err)
                return
            }
            print("Successfully edited the course: ", courseId)
        }
    }
    
}












