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
            print(snapshot)
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user:", err)
        }
    }
    
    static func fetchPostWithPID(pid: String, completion: @escaping (Post) -> ()) {
        
        let ref = Database.database().reference().child("posts")
        ref.child(pid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dic = snapshot.value as? [String: Any] else { return }
            
            let uid = dic["uid"] as! String
            
            fetchUserWithUID(uid: uid, completion: { (user) in
                let post = Post(user: user, postId: pid, dictionary: dic)
               
                completion(post)
            })

        }) { (err) in
            print("Failed to fetch post:", err)
        }
    }
    
    static func fetchPostMessagesWithPID(pid: String, completion: @escaping ([PostMessage]) -> ()) {
        var postMessages = [PostMessage]()
        
        let ref = Database.database().reference().child("post_messages")
        ref.child(pid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dicArr = snapshot.value as? [[String: Any]] else { return }
            
            for count in 0..<dicArr.count {
                let postMessageDic = dicArr[count]
                let postMessage = PostMessage(dictionary: postMessageDic)
                postMessages.append(postMessage)
            }
            
            completion(postMessages)
            
        }) { (err) in
            print("Failed to fetch post:", err)
        }
    }
    
    
    
    static func fetchResponseWithRID(rid: String, completion: @escaping (Response) -> ()) {
        
        let ref = Database.database().reference().child("response")
        ref.child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dic = snapshot.value as? [String: Any] else { return }
            
            let uid = dic["uid"] as! String
            
            fetchUserWithUID(uid: uid, completion: { (user) in
                let response = Response(user: user, responseId: rid, dictionary: dic)
                
                completion(response)
            })
            
        }) { (err) in
            print("Failed to fetch post:", err)
        }
    }
    
    static func fetchResponseMessagesWithRID(rid: String, completion: @escaping ([ResponseMessage]) -> ()) {
        var responseMessages = [ResponseMessage]()
        
        let ref = Database.database().reference().child("response_messages")
        ref.child(rid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dicArr = snapshot.value as? [[String: Any]] else { return }
            
            for count in 0..<dicArr.count {
                let responseMessageDic = dicArr[count]
                let responseMessage = ResponseMessage(dictionary: responseMessageDic)
                responseMessages.append(responseMessage)
            }
            
            completion(responseMessages)
            
        }) { (err) in
            print("Failed to fetch post:", err)
        }
    }
    
}










