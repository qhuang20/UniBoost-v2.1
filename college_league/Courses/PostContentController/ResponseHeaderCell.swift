//
//  ResponseHeaderCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class ResponseHeaderCell: UITableViewCell {
    
    weak var postContentController: PostContentController?
    
    var response: Response? {
        didSet {
            guard let response = response else { return }
            let user = response.user
            
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            setupAttributedCaption()
            setupFollowUnfollowButton()
        }
    }
    
    private func setupAttributedCaption() {
        guard let response = self.response else { return }
        let userBio = response.user.bio ?? ""
        
        var attributedText = NSMutableAttributedString(string: "\(response.user.username)", attributes: attributesForUserInfo)
        if userBio.count > 0 {
            attributedText = NSMutableAttributedString(string: "\(response.user.username): \(userBio)", attributes: attributesForUserInfo)
        }
        
        attributedText.appendNewLine()
        
        let timeAgoDisplay = response.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplay)", attributes: attributesForTime))
        
        attributedText.setLineSpacing(8)
        responseInfoLabel.attributedText = attributedText
    }
    
    private func setupFollowUnfollowButton() {
        guard let user = response?.user else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let userId = user.uid
        
        if userId == currentLoggedInUserId {
            followUnfollowButton.isHidden = true
        } else {
            followUnfollowButton.isHidden = false
            user.hasFollowed ? setupUnfollowStyle() : setupFollowStyle()
        }
    }
    
    let profileImageWidth: CGFloat = 44
    let padding: CGFloat = 8
    
    lazy var profileImageView: CachedImageView = {
        let iv = CachedImageView(cornerRadius: profileImageWidth / 2)
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGotoUserProfile)))
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = brightGray
        return iv
    }()
    
    lazy var responseInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGotoUserProfile)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var followUnfollowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4.5
        button.addTarget(self, action: #selector(handleFollowUnfollow), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(responseInfoLabel)
        contentView.addSubview(followUnfollowButton)
        
        profileImageView.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        responseInfoLabel.anchor(marginGuide.topAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: followUnfollowButton.leftAnchor, topConstant: 3, leftConstant: padding, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        followUnfollowButton.anchor(marginGuide.topAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 55, heightConstant: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleGotoUserProfile() {
        guard let response = response else { return }
        let user = response.user
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        postContentController?.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    
    
    @objc func handleFollowUnfollow() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = response?.user.uid else { return }
        guard let user = response?.user else { return }
        
        checkAllUsersToUpdateFollowButton(user: user)
        
        if followUnfollowButton.titleLabel?.text == "Unfollow" {//unfollow
            changeFollowersCountForUser(isFollowed: false)
            changeFollowingCountForUser(isFollowed: false)
            
            let ref = Database.database().reference().child("user_following").child(currentLoggedInUserId).child(userId)
            ref.removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                print("Successfully unfollowed user:", user.username )
            })
        } else {//follow
            changeFollowersCountForUser(isFollowed: true)
            changeFollowingCountForUser(isFollowed: true)
            
            let ref = Database.database().reference().child("user_following").child(currentLoggedInUserId)
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                print("Successfully followed user: ", user.username )
            }
        }
    }
    
    private func setupFollowStyle() {
        self.followUnfollowButton.setTitle("Follow", for: .normal)
        self.followUnfollowButton.backgroundColor = themeColor
        self.followUnfollowButton.setTitleColor(.white, for: .normal)
    }
    
    private func setupUnfollowStyle() {
        self.followUnfollowButton.setTitle("Unfollow", for: .normal)
        self.followUnfollowButton.backgroundColor = .white
        self.followUnfollowButton.setTitleColor(.black, for: .normal)
    }
    
    private func changeFollowersCountForUser(isFollowed: Bool) {
        guard let userId = response?.user.uid else { return }
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
    
    private func changeFollowingCountForUser(isFollowed: Bool) {
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
    
    
    
    private func checkAllUsersToUpdateFollowButton(user: User) {
        let hasFollowedOldState = user.hasFollowed
        let uid = user.uid
        
        if postContentController?.post?.user.uid == uid {
            postContentController?.post?.user.hasFollowed = !hasFollowedOldState
        }
        postContentController?.responseArr.forEach({ (response) in
            if response.user.uid == uid {
                let i = postContentController?.responseArr.index(of: response)
                postContentController?.responseArr[i!].user.hasFollowed = !hasFollowedOldState
            }
        })
        
        postContentController?.tableView.reloadData()
    }
    
}





