//
//  ResponseFoonterView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class ResponseFoonterView: UIView {
    
    weak var postContentController: PostContentController?
    
    var response: Response? {
        didSet {
            guard let response = response else { return }
            let likes = response.likes
            response.hasLiked ? setupLikedStyle() : setupUnLikedStyle()
            likesLabel.text = "\(likes) likes"
        }
    }
    
    let buttonHeight: CGFloat = 32
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.setImage(#imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = themeColor
        button.addTarget(self, action: #selector(handleLikeResponse), for: .touchUpInside)
        return button
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.text = "100 likes"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = themeColor
        label.numberOfLines = 1
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(#imageLiteral(resourceName: "comment_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        button.tintColor = themeColor
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let dotsButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "dots").withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.tintColor = lightThemeColor
        button.addTarget(self, action: #selector(handleDots), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(commentButton)
        addSubview(likeButton)
        addSubview(likesLabel)
        addSubview(dotsButton)
        
        commentButton.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: buttonHeight - 2, heightConstant: buttonHeight + 4)
        commentButton.anchorCenterYToSuperview()
        
        likeButton.anchor(nil, left: nil, bottom: nil, right: likesLabel.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 2.5, widthConstant: buttonHeight, heightConstant: buttonHeight)
        likeButton.anchorCenterYToSuperview()
        
        likesLabel.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 65, heightConstant: buttonHeight)
        likesLabel.anchorCenterYToSuperview()
        
        dotsButton.anchor(nil, left: commentButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        dotsButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleDots() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.black
        alertController.view.isOpaque = true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive){ (alertAction) in
            self.showReportAlert()
        }
        
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        postContentController?.present(alertController, animated: true, completion: nil)
    }
    
    private func showReportAlert() {
        let alertController = UIAlertController(title: "Report", message: "Thank you for sending us the message", preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Tell us the reason"
        }
        
        let saveAction = UIAlertAction(title: "Send", style: .default, handler: { alert -> Void in
            //            let firstTextField = alertController.textFields![0] as UITextField
            ///report to DB later with uid postId.....
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.postContentController?.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @objc func handleComment() {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.response = response
        postContentController?.navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    
    @objc func handleLikeResponse() {
        guard let response = response else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = [response.responseId: likeButton.isSelected ? 0 : 1]
        let ref = Database.database().reference().child("user_likedResponse").child(uid)
        guard let i = postContentController?.responseArr.index(of: response) else {return}
        
        if likeButton.isSelected {
            self.response?.hasLiked = false
            postContentController?.responseArr[i].hasLiked = false
        } else {
            self.response?.hasLiked = true
            postContentController?.responseArr[i].hasLiked = true
        }
        changeResponseLikesCount()
        changeLikesCountForUser()
        changeLikesCountForSearchUser()
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to like post:", err)
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
    
    private func changeResponseLikesCount() {
        guard let responseId = response?.responseId else { return }
        let ref = Database.database().reference().child("response").child(responseId).child("likes")
        let isSelected = self.likeButton.isSelected
        
        if let i = self.postContentController?.responseArr.index(of: self.response!) {
            let oldLikes = self.response?.likes ?? 0
            self.postContentController?.responseArr[i].likes = isSelected ? oldLikes + 1 : oldLikes - 1
            self.response?.likes = isSelected ? oldLikes + 1 : oldLikes - 1
        }
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isSelected ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase response likes count", error)
                return
            }
            print("Successfully increased response likes count")
        }
    }
    
    private func changeLikesCountForUser() {
        guard let uid = response?.user.uid else { return }
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
    
    private func changeLikesCountForSearchUser() {
        guard let uid = response?.user.uid else { return }
        guard let school = UserDefaults.standard.getSchool() else { return }
        let isSelected = self.likeButton.isSelected
        let ref = Database.database().reference().child("school_users").child(school).child(uid)
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = isSelected ? currentValue + 1 : currentValue - 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase user likes count", error)
                return
            }
            print("Successfully increased school user likes count")
        }
    }
    
}





