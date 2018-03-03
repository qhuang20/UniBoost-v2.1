//
//  CourseController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension CourseController {
    
    internal func fetchCourses() {
        guard let school = school else { return }
        let ref = Database.database().reference().child("school_courses").child(school)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let course = Course(school: school, courseId: key, dictionary: dictionary)
                self.courses.append(course)
            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch courses:", err)
        }
         
    }
    
}
