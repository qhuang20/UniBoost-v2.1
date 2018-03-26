//
//  PostContentControlle+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension PostContentController {
    
    internal func fetchPostMessagesResponse() {
        guard let postId = post?.postId else { return }
        Database.fetchPostMessagesWithPID(pid: postId) { (postMessages) in
            self.postMessages = postMessages
        }
        
        paginateResponse()
    }
    
    internal func paginateResponse() {
        print("\nstart paging")
        guard let postId = post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("post_response").child(postId)
        isPaging = true
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 4
        
        if responseArr.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            var counter = 0
            
            if allObjects.count == 1 || allObjects.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.tableView.reloadData()
            }
            if self.responseArr.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingValue = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let responseId = snapshot.key
                print(responseId)
                
                Database.fetchResponseWithRID(rid: responseId, completion: { (response) in
                    let ref = Database.database().reference().child("user_likedResponse").child(uid).child(responseId)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        var response = response
                        if let value = snapshot.value as? Int, value == 1 {
                            response.hasLiked = true
                        }
                        self.responseArr.append(response)
                        print("inside:   ", response.responseId)
                        
                        Database.fetchResponseMessagesWithRID(rid: responseId) { (responseMessages) in
                            self.responseMessagesDic[responseId] = responseMessages
                            
                            counter = counter + 1
                            if allObjects.count == counter {
                                self.isPaging = false
                                self.tableView.reloadData()
                            }
                        }
                    })
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    
    
    @objc func handleUpdate() {
        if isPaging { return }
        responseArr.removeAll()
        isFinishedPaging = false
        paginateResponse()
    }
    
    @objc func updateResponseCount(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let addFlag = userInfo["add"] as? Bool else { return }
        guard let oldResponseCount = post?.response else { return }
        
        self.post?.response = addFlag ? oldResponseCount + 1 : oldResponseCount - 1
        self.tableView.reloadData()
    }
    
}



