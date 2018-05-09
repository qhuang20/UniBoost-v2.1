//
//  FriendsController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-08.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

extension SearchUsersController: UISearchBarDelegate {
    
    internal func fetchSchoolUsers() {
        guard let school = UserDefaults.standard.getSchool() else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("school_users").child(school)
        let query = ref.queryOrderedByValue()
        let queryNum: UInt = 20
        var counter = 0
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let userId = snapshot.key
                
                Database.fetchUserWithUID(uid: userId, completion: { (user) in
                    let dummyImageView = CachedImageView()//preload image
                    dummyImageView.loadImage(urlString: user.profileImageUrl)
        
                    let userFollowingRef = Database.database().reference().child("user_following").child(currentUid).child(user.uid)
                    userFollowingRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        var user = user
                        if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                            user.hasFollowed = true
                        }
                        
                        self.users.append(user)
                        print("inside:   ", user.uid)
                        
                        counter = counter + 1
                        if allObjects.count == counter {
                            self.users.sort(by: { (u1, u2) -> Bool in
                                u1.likes > u2.likes
                            })
                            
                            self.filteredUsers = self.users
                            self.collectionView?.reloadData()
                        }
                    })
                })
            })
        }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        
        self.collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)//Keyboard Done
    }
    
    
    
    @objc internal func handleUpdateFollowButtonStyle(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let user = userInfo["user"] as? User else { return }
        updateFollowButton(user: user)
    }
    
    private func updateFollowButton(user: User) {
        let hasFollowedNewState = user.hasFollowed
        
        if let i = users.index(of: user) {
            users[i].hasFollowed = hasFollowedNewState
        }
        
        if let j = filteredUsers.index(of: user) {
            filteredUsers[j].hasFollowed = hasFollowedNewState
            
            let indexPath = IndexPath(item: j, section: 0)
            collectionView?.reloadItems(at: [indexPath])
        }
    }
    
}






