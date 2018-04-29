//
//  SearchSkillsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SearchSkillsController: CourseSearchController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(SearchSkillsControllerCell.self, forCellWithReuseIdentifier: courseSearchCellId)
    }
    
    override func didSelectCellAt(indexPath: IndexPath) {
        popUpErrorView(text: "Can't enter the course here")
    }
    
    @objc internal override func paginateCourses() {
        print("\nstart paging")
        isPaging = true
        guard let school = school else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("school_courses").child(school)
        var query = ref.queryOrderedByKey().queryStarting(atValue: courseSearchHit).queryEnding(atValue: courseSearchHit + "\u{f8ff}")
        let queryNum: UInt = 12
        
        if courses.count > 0 {
            query = ref.queryOrderedByKey().queryStarting(atValue: queryEndingCourseId).queryEnding(atValue: courseSearchHit + "\u{f8ff}")
        }
        
        query.queryLimited(toFirst: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            var counter = 0
            
            if allObjects.count == 1 || allObjects.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.collectionView?.reloadData()
                self.showNoMatchesHintLabelIfNeeded()
            }
            if self.courses.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            let lastSnapshot = allObjects.last
            self.queryEndingCourseId = lastSnapshot?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let courseId = snapshot.key
                print(courseId)
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var course = Course(school: school, courseId: courseId, dictionary: dictionary)
                let ref = Database.database().reference().child("user_skills").child(currentLoggedInUserId).child(school).child(courseId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        course.hasFollowed = true
                    }
                    self.courses.append(course)
                    print("inside:   ", course.courseId)
                    
                    counter = counter + 1
                    if allObjects.count == counter {
                        self.isPaging = false
                        self.getFilteredCoursesWith(searchText: self.searchBar.text ?? "")
                        self.courses.sort(by: { (c1, c2) -> Bool in
                            c1.number < c2.number
                        })
                        self.collectionView?.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
}
