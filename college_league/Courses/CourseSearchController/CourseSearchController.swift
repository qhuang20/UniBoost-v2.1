//
//  CourseSearchController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-26.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class CourseSearchController: CourseController {
    
    weak var superCourseController: CourseController?
    
    var courseSearchHit: String = ""
    var queryEndingCourseId: String = ""
    
    var previousSearchText = ""
    
    let courseSearchCellId = "courseSearchCellId"
    
    let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter at least 3 characters"
        label.textColor = UIColor.lightGray
        label.isHidden = true
        return label
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        previousSearchText = searchBar.text ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.showsCancelButton = true
        searchBar.text = previousSearchText
        searchBar.placeholder = "Enter Course Code"
        searchBar.delegate = self
        enableCancelButton(searchBar: searchBar)
        
        guard let searchBarAnchors = searchBarAnchors else { return }
        searchBarAnchors[0].constant = 20
        searchBarAnchors[2].constant = -20
        animateNavigationBarLayout()
    }
    
    override func viewDidLoad() {
        configureCollectionVeiw()
        collectionView?.register(CourseSearchControllerCell.self, forCellWithReuseIdentifier: courseSearchCellId)
        school = UserDefaults.standard.getSchool()
        isFinishedPaging = true
        
        searchBar.showsCancelButton = true
        searchBar.subviews.forEach { (subview) in
            if subview.isKind(of: UIButton.self) {
                subview.isUserInteractionEnabled = true
            }
        }
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBarAnchors = searchBar.anchorWithReturnAnchors(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 2, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        searchBar.becomeFirstResponder()
        
        view.addSubview(hintLabel)
        hintLabel.anchorCenterXToSuperview()
        hintLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 32, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeCourseColor), name: PostController.updateCourseColorNotificationName, object: nil)
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging && courseSearchHit.count == 3 {
            paginateCourses()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: courseSearchCellId, for: indexPath) as! CourseSearchControllerCell
        cell.course = filteredCourses[indexPath.item]
        cell.courseController = self
        cell.superCourseController = superCourseController
        return cell
    }
    
    
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            hintLabel.isHidden = false
            hintLabel.text = "Enter at least 3 characters"
            
            isFinishedPaging = true
            courses.removeAll()
            filteredCourses.removeAll()
            collectionView?.reloadData()
            return
        }
        if searchText.count == 3 {
            hintLabel.isHidden = true
            
            if courses.count == 0 {
                let searchText = searchText.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                courseSearchHit = searchText.uppercased()
                isFinishedPaging = false
                collectionView?.reloadData()
            }
        }
        
        if !isFinishedPaging && !isPaging {
            paginateCourses()
        }
        
        if isFinishedPaging {
            self.getFilteredCoursesWith(searchText: searchText)
            self.collectionView?.reloadData()
        }
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)//Keyboard Done
    }
    
    override func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool { return true }
    override func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    override func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}

    
    
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
    
    
    
    override func getFilteredCoursesWith(searchText: String) {
        let searchText = searchText.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        filteredCourses = self.courses.filter { (course) -> Bool in
            let courseName = course.name + course.number + course.description
            return courseName.lowercased().contains(searchText.lowercased())
        }
        
        if isFinishedPaging {
            showNoMatchesHintLabelIfNeeded()
        }
    }
    
    internal func showNoMatchesHintLabelIfNeeded() {
        if filteredCourses.count == 0 {
            hintLabel.isHidden = false
            hintLabel.text = "Ops, no matches, try it again"///add report an issue button later
        } else {
            hintLabel.isHidden = true
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
    }
    
    private func enableCancelButton (searchBar : UISearchBar) {
        for view1 in searchBar.subviews {
            for view2 in view1.subviews {
                if view2.isKind(of: UIButton.self) {
                    let button = view2 as! UIButton
                    button.isEnabled = true
                    button.isUserInteractionEnabled = true
                }
            }
        }
    }
    
}

















