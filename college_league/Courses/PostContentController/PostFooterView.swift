//
//  PostFooterView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-14.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class PostFooterView: UIView {
    
    weak var postContentController: PostContentController?
    
    static let updateProfileBookmarksNotificationName = NSNotification.Name(rawValue: "UpdateProfileBookmarks")
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            post.hasLiked ? setupLikedStyle() : setupUnLikedStyle()
            post.hasBookmarked ? setupBookmarkedStyle() : setupUnBookmarkedStyle()
        }
    }
    
    static let updatePostLikesCountName = NSNotification.Name(rawValue: "updatePostLikesCount")
    
    let respondButtonColor = UIColor.init(r: 255, g: 244, b: 186)
    let buttonHeight: CGFloat = 32
    
    lazy var respondButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Respond", for: UIControlState.normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = themeColor
        button.backgroundColor = respondButtonColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleRespond), for: .touchUpInside)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.setImage(#imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = themeColor
        button.addTarget(self, action: #selector(handleLikePost), for: .touchUpInside)
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "bookmark_unselected").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(#imageLiteral(resourceName: "bookmark_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        button.tintColor = themeColor
        button.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(respondButton)
        addSubview(bookmarkButton)
        addSubview(likeButton)

        respondButton.anchorCenterSuperview()
        respondButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 116, heightConstant: 0)
        
        bookmarkButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 22, widthConstant: buttonHeight, heightConstant: buttonHeight)
        bookmarkButton.anchorCenterYToSuperview()
        
        likeButton.anchor(nil, left: nil, bottom: nil, right: bookmarkButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: buttonHeight, heightConstant: buttonHeight)
        likeButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    @objc func handleRespond() {
        let responseController = ResponseController()
        let navTitleTypeController = UINavigationController(rootViewController: responseController)
        let postId = postContentController?.post?.postId
        responseController.postId = postId
        postContentController?.present(navTitleTypeController, animated: true, completion: nil)
    }
    
    
    
    @objc func handleBookmark() {
        guard let post = postContentController?.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = [post.postId: Date().timeIntervalSince1970]
        let ref = Database.database().reference().child("user_bookmarks").child(uid)
        
        if bookmarkButton.isSelected {
            self.post?.hasBookmarked = false
            postContentController?.post?.hasBookmarked = false//isSelected changed
        } else {
            self.post?.hasBookmarked = true
            postContentController?.post?.hasBookmarked = true
        }
        
        if bookmarkButton.isSelected {
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to bookmark post:", err)
                    return
                }
                print("Successfully bookmarked post.")
                
                NotificationCenter.default.post(name: PostFooterView.updateProfileBookmarksNotificationName, object: nil)
            }
        } else {
            ref.child(post.postId).removeValue { (err, ref) in
                NotificationCenter.default.post(name: PostFooterView.updateProfileBookmarksNotificationName, object: nil)
            }
        }
    }
    
    private func setupBookmarkedStyle() {
        bookmarkButton.isSelected = true
        bookmarkButton.tintColor = UIColor(r: 0, g: 130, b: 106)
    }
    
    private func setupUnBookmarkedStyle() {
        bookmarkButton.isSelected = false
        bookmarkButton.tintColor = themeColor
    }
    
    
    
    @objc func handleLikePost() {
        guard let post = postContentController?.post else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = [post.postId: likeButton.isSelected ? 0 : 1]
        let ref = Database.database().reference().child("user_likedPosts").child(uid)
        
        if likeButton.isSelected {
            self.post?.hasLiked = false
            postContentController?.post?.hasLiked = false
        } else {
            self.post?.hasLiked = true
            postContentController?.post?.hasLiked = true
        }
        changePostLikesCount()
        changePostLikesCountForTrendingCell()
        changeLikesCountForUser()
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to liked post:", err)
                return
            }
            print("Successfully liked post.")
        }
    }
    
    private func setupLikedStyle() {
        likeButton.isSelected = true
        likeButton.tintColor = UIColor.red
    }
    
    private func setupUnLikedStyle() {
        likeButton.isSelected = false
        likeButton.tintColor = themeColor
    }
    
    private func changePostLikesCount() {
        guard let postId = post?.postId else { return }
        let ref = Database.database().reference().child("posts").child(postId).child("likes")
        let isSelected = self.likeButton.isSelected
        
        let userInfo = ["postId": postId, "liked": isSelected] as [String : Any]
        NotificationCenter.default.post(name: PostFooterView.updatePostLikesCountName, object: nil, userInfo: userInfo)
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isSelected ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase post likes count", error)
                return
            }
            print("Successfully increased post likes count")
        }
    }
    
    private func changePostLikesCountForTrendingCell() {
        guard let course = post?.course else { return }
        guard let postId = post?.postId else { return }
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId).child(postId)
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = currentValue + 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase post likes count for TrendingCell", error)
                return
            }
            print("Successfully increased post likes count for TrendingCell")
        }
    }
    
    private func changeLikesCountForUser() {
        guard let uid = post?.user.uid else { return }
        let isSelected = self.likeButton.isSelected
        let ref = Database.database().reference().child("users").child(uid).child("likes")
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isSelected ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase user likes count", error)
                return
            }
            print("Successfully increased user likes count")
        }
    }
    
}









