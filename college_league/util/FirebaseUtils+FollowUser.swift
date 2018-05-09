//
//  FirebaseUtils+FollowUser.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-09.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Firebase

extension Database {
    
    static func unfollowUser(uid: String) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.changeFollowersCountForUser(uid: uid, isFollowed: false)
        Database.changeFollowingCountForUser(isFollowed: false)
        
        let ref = Database.database().reference().child("user_following").child(currentLoggedInUserId).child(uid)
        ref.removeValue(completionBlock: { (err, ref) in
            if let err = err {
                print("Failed to unfollow user:", err)
                return
            }
            print("Successfully unfollowed user:", uid)
        })
        
        let userFollowersRef = Database.database().reference().child("user_followers").child(uid).child(currentLoggedInUserId)
        userFollowersRef.removeValue(completionBlock: { (err, ref) in
            if let err = err {
                print("Failed to remove follower:", err)
                return
            }
            print("Successfully remove follower:", currentLoggedInUserId)
        })
    }
    
    static func followUser(uid: String) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.changeFollowersCountForUser(uid: uid, isFollowed: true)
        Database.changeFollowingCountForUser(isFollowed: true)
        
        let ref = Database.database().reference().child("user_following").child(currentLoggedInUserId)
        let values = [uid: 1]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to follow user:", err)
                return
            }
            print("Successfully followed user: ", uid)
        }
        
        let userFollowersRef = Database.database().reference().child("user_followers").child(uid)
        let userFollowersValues = [currentLoggedInUserId: 1]
        userFollowersRef.updateChildValues(userFollowersValues) { (err, ref) in
            if let err = err {
                print("Failed to add follower:", err)
                return
            }
            print("Successfully add follower: ", currentLoggedInUserId)
        }
    }
    
    
    
    static func changeFollowersCountForUser(uid: String, isFollowed: Bool) {
        let userId = uid
        let ref = Database.database().reference().child("users").child(userId).child("followers")
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isFollowed ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase user followers count", error)
                return
            }
            print("Successfully increased user followers count")
        }
    }
    
    static func changeFollowingCountForUser(isFollowed: Bool) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(currentLoggedInUserId).child("following")
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isFollowed ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase user following count", error)
                return
            }
            print("Successfully increased user following count")
        }
    }
    
}
