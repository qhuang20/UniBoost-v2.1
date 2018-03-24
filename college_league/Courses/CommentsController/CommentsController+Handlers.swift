//
//  CommentsController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-24.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension CommentsController {
    
    internal func paginatePosts() {
        print("\nstart paging")
        isPaging = true
        guard let responseId = self.response?.responseId else { return }
        let ref = Database.database().reference().child("response_comments").child(responseId)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 12
        
        if comments.count > 0 {
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
            if self.comments.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingValue = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let commentId = snapshot.key
                print(commentId)
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                guard let toUid = dictionary["toUid"] as? String else { return }
                
                Database.fetchUserWithUID(uid: uid, completion: { (user) in
                    Database.fetchUserWithUID(uid: toUid, completion: { (toUser) in
                        let comment = Comment(user: user, toUser: toUser, dictionary: dictionary)
                        self.comments.insert(comment, at: 0)
                        print("inside:   ", commentId)
                        
                        counter = counter + 1
                        if allObjects.count == counter {
                            self.isPaging = false
                            self.comments.sort(by: { (c1, c2) -> Bool in
                                c1.creationDate.compare(c2.creationDate) == .orderedAscending
                            })
                            self.collectionView?.reloadData()
                            
                            if self.scrollToBottomOneTimeFlag {
                                self.scrollToBottom()
                                if allObjects.count < queryNum {
                                    self.paginatePosts()
                                }
                            } else {
                                let indexPath = IndexPath(row: allObjects.count + 1, section: 0)
                                self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
                                let point = CGPoint(x: 0, y: -self.loadingCellHeight + (self.collectionView?.contentOffset.y)!)
                                self.collectionView?.setContentOffset(point, animated: false)
                            }
                            self.scrollToBottomOneTimeFlag = false
                        }
                    })
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    internal func fetchNewComment() {
        guard let responseId = self.response?.responseId else { return }
        let ref = Database.database().reference().child("response_comments").child(responseId)
        let query = ref.queryOrderedByKey().queryLimited(toLast: 1)
        newCommentRef = ref
        
        query.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            guard let toUid = dictionary["toUid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                Database.fetchUserWithUID(uid: toUid, completion: { (toUser) in
                    if self.firstNewCommentOneTimeFlag {
                        let comment = Comment(user: user, toUser: toUser, dictionary: dictionary)
                        self.comments.append(comment)
                        self.collectionView?.reloadData()
                        
                        let offset = self.collectionView?.contentOffset.y ?? 0
                        let frameHeight = self.collectionView?.frame.height ?? 0
                        let contentViewHeight = self.collectionView?.contentSize.height ?? 0
                        if contentViewHeight - offset < frameHeight {
                            self.scrollToBottom()
                        }
                    }
                    self.firstNewCommentOneTimeFlag = true
                })
            })
        }) { (err) in
            print("Failed to observe comments")
        }
    }
    
    
    
    @objc func handleSend() {
        guard let text = commentTextField.text, text.count > 0 else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let toUid = toUser?.uid else { return }
        let responseId = self.response?.responseId ?? ""
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid, "toUid": toUid] as [String : Any]
        let ref = Database.database().reference().child("response_comments").child(responseId).childByAutoId()
        commentTextField.text = nil
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment:", err)
                return
            }
            print("Successfully inserted comment.")
        }
    }
    
    @objc func handleKeyboardDidShow(_ notification: Notification) {
        let keyboardFrameHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.height
        if comments.count > 0 && keyboardFrameHeight > 55 {
            scrollToBottom()
        }
    }
    
}

