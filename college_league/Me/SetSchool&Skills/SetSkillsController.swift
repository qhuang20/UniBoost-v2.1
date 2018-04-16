//
//  SetSkillsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SetSkillsController: CourseController {
    
    static let addSkillNotificationName = NSNotification.Name(rawValue: "AddSkill")
    
    override func viewDidLoad() {
        configureCollectionVeiw()
        configureNavigationBar()
        
        view.addSubview(pleaseAddCourseLabel)
        pleaseAddCourseLabel.anchor(view?.safeAreaLayoutGuide.topAnchor, left: view?.leftAnchor, bottom: nil, right: view?.rightAnchor, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
        pleaseAddCourseLabel.isHidden = true
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBarAnchors = searchBar.anchorWithReturnAnchors(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 50, bottomConstant: 2, rightConstant: 60, widthConstant: 0, heightConstant: 0)
        
        school = UserDefaults.standard.getSchool()
        if school == nil {
            isFinishedPaging = true
            self.collectionView?.reloadData()
            
            navigationController?.popViewController(animated: true)
            return
        }
        
        fetchFollowingCourses()
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchBar.alpha = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        previousSearchText = searchBar.text ?? ""
        
        if (self.isMovingFromParentViewController || self.isBeingDismissed) {//better than deinit
            NotificationCenter.default.post(name: SetSkillsController.addSkillNotificationName, object: nil)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.alpha = 0
        }) { (_) in
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.text = previousSearchText
        searchBar.placeholder = "Select Your Skill"
        searchBar.delegate = self
        
        guard let searchBarAnchors = searchBarAnchors else { return }
        searchBarAnchors[0].constant = 50
        searchBarAnchors[2].constant = -60
        animateNavigationBarLayout()
    }
    
    internal override func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        
        collectionView?.register(SetSkillsControllerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: loadingCellId)
    }
    
    
    
    override func didSelectCellAt(indexPath: IndexPath) {
        print("show hint")///
    }
    
    
    
    internal override func paginateCourses() {
        print("\nstart paging")
        isPaging = true
        guard let school = school else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("school_courses").child(school)
        var query = ref.queryOrdered(byChild: "postsCount")
        let queryNum: UInt = 9
        
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
                            c1.postsCount > c2.postsCount
                        })
                        self.collectionView?.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    internal override func fetchFollowingCourses() {
        guard let school = school else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user_skills").child(currentLoggedInUserId).child(school)
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
    
}










