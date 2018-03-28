//
//  UserProfileController+Handlers.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension UserProfileController {
    
    internal func fetchUserAndUserPosts() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        let userFollowingRef = Database.database().reference().child("user_following").child(currentLoggedInUserId).child(uid)
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.refreshControl.endRefreshing()
            self.user = user
            self.navigationItem.title = self.user?.username
            
            userFollowingRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.user?.hasFollowed = true
                }
                
                self.collectionView?.reloadData()
            })
            
            self.paginatePosts()
        }
    }
    
    internal func paginatePosts() {
        print("\nstart paging")
        isPaging = true
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("user_posts").child(uid)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 6
        
        if posts.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue)
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
            if self.posts.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingValue = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                print(postId)
                
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    self.posts.append(post)
                    print("inside:   ", post.postId)
                    
                    counter = counter + 1
                    if allObjects.count == counter {
                        self.isPaging = false
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == ComparisonResult.orderedDescending
                        })
                        self.collectionView?.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    @objc func handleRefresh() {
        if isPaging { return }
        posts.removeAll()
        self.isFinishedPaging = false
        fetchUserAndUserPosts()
    }

    
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
}
