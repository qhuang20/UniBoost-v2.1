//
//  FirebaseUtils.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        let ref = Database.database().reference().child("users")
        ref.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
    
    static func fetchPostInfoWithPID(pid: String, completion: @escaping (PostInfo) -> ()) {
        
        let ref = Database.database().reference().child("post_Info")
        ref.child(pid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let postInfoDictionary = snapshot.value as? [String: Any] else { return }
            
            let uid = postInfoDictionary["uid"] as! String
            
            fetchUserWithUID(uid: uid, completion: { (user) in
                let postInfo = PostInfo(user: user, postId: pid, dictionary: postInfoDictionary)
               
                completion(postInfo)
            })

        }) { (err) in
            print("Failed to fetch postInfo:", err)
        }
    }
    
}

