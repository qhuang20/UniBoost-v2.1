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
   
    @objc internal func paginateCourses() {
        print("\nstart paging")
        isPaging = true
        guard let school = school else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("school_courses").child(school)
        var query = ref.queryOrdered(byChild: "postsCount")
        let queryNum: UInt = 12
        
        if courses.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue, childKey: queryEndingChildKey)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            var counter = 0
            
            if allObjects.count == 1 || allObjects.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.collectionView?.reloadData()
            }
            if self.courses.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            let lastSnapshot = allObjects.last
            guard let dictionary = lastSnapshot?.value as? [String: Any] else { return }
            self.queryEndingValue = dictionary["postsCount"] as? Int ?? 0
            self.queryEndingChildKey = lastSnapshot?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let courseId = snapshot.key
                print(courseId)
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var course = Course(school: school, courseId: courseId, dictionary: dictionary)
                let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school).child(courseId)
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
                            c1.postsCount > c2.postsCount
                        })
                        self.collectionView?.reloadData()
                        
                        if self.loadingView.alpha == 1 {
                            self.loadingView.rocketCenterYAnchor?.constant = -300
                            
                            UIView.animate(withDuration: 0.3, delay: 0.8, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                                self.loadingView.alpha = 0
                                self.view.layoutIfNeeded()
                            }, completion: nil)
                        }
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    @objc internal func fetchFollowingCourses() {
        guard let school = school else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let coursesDic = snapshot.value as? [String: Any] else { return }
            var counter = 0
            
            coursesDic.forEach({ (courseId, value) in
                let ref = Database.database().reference().child("school_courses").child(school).child(courseId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    
                    if let value = value as? Int, value == 1 {
                        var course = Course(school: school, courseId: courseId, dictionary: dictionary)
                        course.hasFollowed = true
                        self.followingCourses.append(course)
                    }
                    
                    counter = counter + 1
                    if counter == coursesDic.count {
                        if UserDefaults.standard.isEyeSelected() {
                            self.handleViewOption()
                        }
                    }
                })
            })
        })
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !isFinishedPaging && !isPaging {
            paginateCourses()
        }
        
        if isFinishedPaging {
            self.getFilteredCoursesWith(searchText: searchText)
            self.collectionView?.reloadData()
        }
    }
    
    @objc internal func getFilteredCoursesWith(searchText: String) {
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
        
        if filteredCourses.isEmpty {
            if !isFinishedPaging && !isPaging {
                paginateCourses()
            }
        }
    }
    
    
    
    @objc func handleViewOption() {
        searchBar.text = nil
        pleaseAddCourseLabel.isHidden = true
        
        if viewOptionButton?.isSelected == true {
            viewOptionButton?.isSelected = false
            UserDefaults.standard.setEyeSelected(value: false)
            viewOptionButton?.isEnabled = false
            isFinishedPaging = false
            filteredCourses = courses
            collectionView?.reloadData()
            viewOptionButton?.isEnabled = true
        } else {
            viewOptionButton?.isSelected = true
            UserDefaults.standard.setEyeSelected(value: true)
            viewOptionButton?.isEnabled = false
            isFinishedPaging = true
            filteredCourses = followingCourses
            if followingCourses.count == 0 {
                pleaseAddCourseLabel.isHidden = false
            }
            collectionView?.reloadData()
            viewOptionButton?.isEnabled = true
        }
    }
    
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let courseSearchController = CourseSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let navCourseSearchController = UINavigationController(rootViewController: courseSearchController)
        navCourseSearchController.modalPresentationStyle = .overFullScreen
        navCourseSearchController.modalTransitionStyle = .crossDissolve
        present(navCourseSearchController, animated: true, completion: nil)
        return false
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
    
    
    
    @objc internal func handleChangeCourseColor(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let course = userInfo["course"] as? Course else { return }
        
        if let i = filteredCourses.index(of: course) {
            let oldPostsCount = filteredCourses[i].postsCount
            filteredCourses[i].postsCount = oldPostsCount + 1
            self.filteredCourses.sort(by: { (c1, c2) -> Bool in
                c1.postsCount > c2.postsCount
            })
        }
        if let j = courses.index(of: course) {
            let oldPostsCount = courses[j].postsCount
            courses[j].postsCount = oldPostsCount + 1
            self.courses.sort(by: { (c1, c2) -> Bool in
                c1.postsCount > c2.postsCount
            })
        }
        if let k = followingCourses.index(of: course) {
            let oldPostsCount = followingCourses[k].postsCount
            followingCourses[k].postsCount = oldPostsCount + 1
        }
        collectionView?.reloadData()
    }

}










