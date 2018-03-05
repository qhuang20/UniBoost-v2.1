//
//  CourseController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension CourseController: UISearchBarDelegate {
    
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
            
            self.courses.sort(by: { (c1, c2) -> Bool in ///also go fix discussionCell
                let c1Name = c1.name + c1.number
                let c2Name = c2.name + c2.number
                return c1Name.compare(c2Name) == .orderedDescending
            })
            
            self.filteredCourses = self.courses
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch courses:", err)
        }
         
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCourses = courses
        } else {
            filteredCourses = self.courses.filter { (course) -> Bool in
                let courseName = course.name + course.number + course.description
                return courseName.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

}










