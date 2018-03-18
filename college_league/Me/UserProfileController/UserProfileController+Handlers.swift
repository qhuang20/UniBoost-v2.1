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
        let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.refreshControl.endRefreshing()
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            
            self.paginatePosts()
        }
    }
    
    internal func paginatePosts() {
        print("start paing")
        isPaging = true
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("user_posts").child(uid)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 4
        
        if posts.count > 0 {
            let value = posts.last?.postId
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            self.activityIndicatorView.stopAnimating()
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            
            if allObjects.count == 1 { self.isFinishedPaging = true }
            self.collectionView?.reloadData()
            if self.posts.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    self.posts.append(post)
                    if allObjects.last == snapshot {
                        self.collectionView?.reloadData()
                        self.isPaging = false
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    @objc func handleRefresh() {
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
