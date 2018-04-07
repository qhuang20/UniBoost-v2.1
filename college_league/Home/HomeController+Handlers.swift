//
//  HomeController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-01.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

extension HomeController {
    
    //Note: query and children.allObjects will always get through.
    internal func fetchFollowingUserPostIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let followingRef = Database.database().reference().child("user_following").child(uid)
        let query = followingRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in//outside
            self.refreshControl.endRefreshing()
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if allObject.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.collectionView?.reloadData()
            }
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            var usersCounter = 0
            
            userIdsDictionary.forEach({ (uid, value) in
                print("uid:   ", uid)
                let ref = Database.database().reference().child("user_posts").child(uid)
                let query = ref.queryOrderedByKey()
                let queryNum: UInt = 10
                
                query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in//inside
                    guard let postIdsDictionary = snapshot.value as? [String: Any] else {return}
                    usersCounter = usersCounter + 1
                    var postIdsCounter = 0
                    
                    postIdsDictionary.forEach({ (postId, value) in
                        print(postId)
                        self.postIds.append(postId)
                        postIdsCounter = postIdsCounter + 1
                        
                        if postIdsDictionary.count == postIdsCounter && userIdsDictionary.count == usersCounter {
                            print("postIdsCounter:   ", postIdsCounter)
                            print("usersCounter:   ", usersCounter)
                            
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
    
    internal func paginatePosts() {
        print("\nstart paging")
        let queryNum = 4
        isPaging = true
        var endIndex = queryStartingIndex + queryNum
        if endIndex >= postIds.count - 1 {
            endIndex = postIds.count - 1
            isFinishedPaging = true
        }
        let subPostIds = postIds[queryStartingIndex...endIndex]
        queryStartingIndex = endIndex + 1
        var counter = 0
        
        subPostIds.forEach { (postId) in
            Database.fetchPostWithPID(pid: postId, completion: { (post) in
                self.posts.append(post)
                print("inside:   ", post.postId)
                let dummyImageView = CachedImageView()//preload image
                dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                
                counter = counter + 1
                if subPostIds.count == counter {
                    self.isPaging = false
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    
    
    @objc func handleRefresh() {
        if isPaging { return }
        postIds.removeAll()
        posts.removeAll()
        queryStartingIndex = 0
        self.isFinishedPaging = false
        fetchFollowingUserPostIds()
    }
    
    @objc func handleTimetable() {
        let timetableController = TimetableController()
        present(timetableController, animated: true, completion: nil)
    }
    
}

