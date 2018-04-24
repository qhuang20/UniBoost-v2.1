//
//  UserProfileController+Handlers.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

extension UserProfileController {
    
    internal func fetchUserAndUserPosts() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        let userFollowingRef = Database.database().reference().child("user_following").child(currentLoggedInUserId).child(uid)
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            if self.refreshControl.isRefreshing {//prevent jerky scrolling!!!!!
                self.refreshControl.endRefreshing()
            }
            self.user = user
            self.navigationItem.title = self.user?.username
            
            userFollowingRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.user?.hasFollowed = true
                }
                
                self.collectionView?.reloadData()
            })
            
            if self.choice == TooBarChoice.posts {
                self.paginatePosts()
            } else if self.choice == TooBarChoice.bookmarks {
                self.paginateBookmarks()
            } else {
                self.paginateResponse()
            }
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
            query = query.queryEnding(atValue: queryEndingKey)
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
            self.queryEndingKey = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                print(postId)
                
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    self.posts.append(post)
                    print("inside:   ", post.postId)
                    let dummyImageView = CachedImageView()//preload image
                    dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                    
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
    
    internal func paginateBookmarks() {
        print("\nstart paging bookmarks")
        isPaging = true
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("user_bookmarks").child(uid)
        var query = ref.queryOrderedByValue()
        let queryNum: UInt = 6
        
        if posts.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue.timeIntervalSince1970, childKey: queryEndingKey)
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
            self.queryEndingKey = allObjects.last?.key ?? ""
            let lastSnapshot = allObjects.last
            guard let secondsFrom1970 = lastSnapshot?.value as? TimeInterval else { return }
            self.queryEndingValue = Date(timeIntervalSince1970: secondsFrom1970)
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                print(postId)
                
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    self.posts.append(post)
                    print("inside:   ", post.postId)
                    let dummyImageView = CachedImageView()//preload image
                    dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                    
                    counter = counter + 1
                    if allObjects.count == counter {
                        self.isPaging = false
                        self.collectionView?.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for bookmarks:", err)
        }
    }
    
    internal func paginateResponse() {
        print("\nstart paging reponse")
        isPaging = true
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("user_response").child(uid)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 6
        
        if responseArr.count > 0 {
            query = query.queryEnding(atValue: queryEndingKey)
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
            if self.responseArr.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingKey = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let responseId = snapshot.key
                print(responseId)
                
                Database.fetchResponseWithRID(rid: responseId, completion: { (response) in
                    Database.fetchPostWithPID(pid: response.postId, completion: { (post) in
                        var response = response
                        response.post = post
                        self.responseArr.append(response)
                        print("inside:   ", response.responseId)
                        
                        counter = counter + 1
                        if allObjects.count == counter {
                            self.isPaging = false
                            self.responseArr.sort(by: { (r1, r2) -> Bool in
                                return r1.creationDate.compare(r2.creationDate) == ComparisonResult.orderedDescending
                            })
                            self.collectionView?.reloadData()
                        }
                    })
                })
            })//forEach ends
        }) { (err) in
            print("Failed to paginate for response:", err)
        }
    }
    
    @objc func handleRefresh() {
        if isPaging { return }
        posts.removeAll()
        responseArr.removeAll()
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
    
    
    
    internal func didChangeToolBarChoice(choice: TooBarChoice) {
        print("new choice:   ", choice.rawValue)
        self.choice = choice
        posts.removeAll()
        responseArr.removeAll()
        self.isFinishedPaging = false
        collectionView?.reloadData()

        if self.choice == TooBarChoice.posts {
            self.paginatePosts()
        } else if self.choice == TooBarChoice.bookmarks {
            self.paginateBookmarks()
        } else {
            self.paginateResponse()
        }
    }
    
    internal func showEditProfileController() {//when school == nil
        let editProfileController = EditProfileController()
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            editProfileController.user = user
            let navEditProfileController = UINavigationController(rootViewController: editProfileController)
            self.present(navEditProfileController, animated: true, completion: nil)
        }
    }
    
}






