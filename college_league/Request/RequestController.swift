//
//  RequestController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class RequestController: HomeController {
    
    var school: String?
    
    override func viewDidLoad() {
        configureCollectionVeiw()
        configureNavigationBar()
        
        school = UserDefaults.standard.getSchool()
        if school == nil {///...set up school in Me...
            isFinishedPaging = true
            self.collectionView?.reloadData()
            return
        }
        
        fetchUserSkillsPostIds()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "Can You Help"
    }
    
        
    
    //Note: query and children.allObjects will always get through.
    private func fetchUserSkillsPostIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let school = school else { return }
        let followingRef = Database.database().reference().child("user_skills").child(uid).child(school)
        let query = followingRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in//outside
            if self.refreshControl.isRefreshing {//prevent jerky scrolling!!!!!
                self.refreshControl.endRefreshing()
            }
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if allObject.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.collectionView?.reloadData()
            }
            guard let courseIdsDictionary = snapshot.value as? [String: Any] else {return}
            var skillsCounter = 0
            
            courseIdsDictionary.forEach({ (courseId, value) in
                print("courseId:   ", courseId)
                let ref = Database.database().reference().child("school_course_posts").child(school).child(courseId)
                let query = ref.queryOrderedByKey()
                let queryNum: UInt = 20
                
                query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in//inside
                    skillsCounter = skillsCounter + 1///////????
                    guard let postIdsDictionary = snapshot.value as? [String: Any] else {
//                        if courseIdsDictionary.count == skillsCounter {

                        self.postIds.sort(by: { (s1, s2) -> Bool in
                            return s1.compare(s2) == ComparisonResult.orderedDescending
                        })
                        self.postIds.forEach({ (s) in
                            print("sorted postIds:   ", s)
                        })
                        
                        self.paginatePosts()
//                        }
                        return
                    }
                    var postIdsCounter = 0
                    
                    postIdsDictionary.forEach({ (postId, value) in
                        print(postId)
                        self.postIds.append(postId)
                        postIdsCounter = postIdsCounter + 1
                        
                        if postIdsDictionary.count == postIdsCounter && courseIdsDictionary.count == skillsCounter {///also what if no posts in the skill (check home!!)
                            print("last skill postIdsCounter:   ", postIdsCounter)
                            print("skillsCounter:   ", skillsCounter)
                            
                            self.postIds.sort(by: { (s1, s2) -> Bool in
                                return s1.compare(s2) == ComparisonResult.orderedDescending
                            })
                            self.postIds.forEach({ (s) in
                                print("sorted postIds:   ", s)
                            })
                            
                            self.paginatePosts()
                        }
                    })
                })
            })
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
    @objc override func handleRefresh() {
        if isPaging { return }
        postIds.removeAll()
        posts.removeAll()
        queryStartingIndex = 0
        self.isFinishedPaging = false
        fetchUserSkillsPostIds()
    }
    
}





