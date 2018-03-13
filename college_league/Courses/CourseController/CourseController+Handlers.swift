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
    
    private func fetchFollowingCourses() {
        var followingCourseIds = [String]()

        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = school else { return }
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                print("no followings")///
                self.viewOptionButton?.isSelected = false
                self.viewOptionButton?.isEnabled = true
                return
            }
            
            dictionaries.forEach({ (key, value) in
                let courseId = key
                followingCourseIds.append(courseId)
            })
            
            self.followingCourses = self.courses.filter({ (course) -> Bool in
                var isMatch = false
                
                followingCourseIds.forEach({ (followingCourseId) in
                    if followingCourseId == course.courseId {
                        isMatch = true
                        return
                    }
                })
                return isMatch
            })

            self.filteredCourses = self.followingCourses
            self.collectionView?.reloadData()
            self.viewOptionButton?.isEnabled = true
        }
    }
    
    @objc func handleViewOption() {
        if courses.count == 0 { return }
        searchBar.text = nil
        
        if viewOptionButton?.isSelected == true {
            viewOptionButton?.isSelected = false
            viewOptionButton?.isEnabled = false
            filteredCourses = courses
            collectionView?.reloadData()
            viewOptionButton?.isEnabled = true
        } else {
            viewOptionButton?.isSelected = true
            viewOptionButton?.isEnabled = false
            fetchFollowingCourses()
        }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if viewOptionButton?.isSelected == false {
            if searchText.isEmpty {
                filteredCourses = courses
            } else {
                filteredCourses = self.courses.filter { (course) -> Bool in
                    let courseName = course.name + course.number + course.description
                    return courseName.lowercased().contains(searchText.lowercased())
                }
            }
        } else {
            if searchText.isEmpty {
                filteredCourses = followingCourses
            } else {
                filteredCourses = self.followingCourses.filter { (course) -> Bool in
                    let courseName = course.name + course.number + course.description
                    return courseName.lowercased().contains(searchText.lowercased())
                }
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










