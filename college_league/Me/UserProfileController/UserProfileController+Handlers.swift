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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            
            self.fetchUserPosts()
        }
    }
    
    private func fetchUserPosts() {
        guard let uid = self.user?.uid else { return }
        let ref = Database.database().reference().child("user_posts").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let postId = snapshot.key
            Database.fetchPostWithPID(pid: postId, completion: { (post) in
                self.posts.insert(post, at: 0)
                self.collectionView?.reloadData()
            })
        }) { (err) in
            print("Failed to fetch user posts:", err)
        }
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
