//
//  PostContentCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-06.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class PostHeaderCell: UITableViewCell {
    
    weak var postContentController: PostContentController?
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            let user = post.user
            
            titleLabel.text = post.title
            typeImageView.image = UIImage(named: post.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            
            setupAttributedCaption()
            setupFollowUnfollowButton()
        }
    }
    
    private func setupAttributedCaption() {
        guard let post = self.post else { return }
        let userBio = post.user.bio ?? ""
        
        var attributedText = NSMutableAttributedString(string: "\(post.user.username)", attributes: attributesForUserInfo)
        if userBio.count > 0 {
            attributedText = NSMutableAttributedString(string: "\(post.user.username): \(userBio)", attributes: attributesForUserInfo)
        }
        
        attributedText.appendNewLine()
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let responseCount = post.response
        let likes = post.likes
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplay) • \(responseCount) response • \(likes) likes", attributes: attributesTimeResponseLike))
        
        attributedText.setLineSpacing(8)
        postInfoLabel.attributedText = attributedText
    }
    
    private func setupFollowUnfollowButton() {
        guard let user = post?.user else { return }
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
    let typeImageWidth: CGFloat = 20
    let padding: CGFloat = 8
    
    let typeImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor.lightGray
        return iv
    }()
    
    lazy var profileImageView: CachedImageView = {
        let iv = CachedImageView(cornerRadius: profileImageWidth / 2)
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGotoUserProfile)))
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = brightGray
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.text = "Sample Title"
        return label
    }()
    
    lazy var postInfoLabel: UILabel = {
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(typeImageView)
        contentView.addSubview(postInfoLabel)
        contentView.addSubview(followUnfollowButton)
        
        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageView.anchor(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding + 13, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        
        typeImageView.anchor(titleLabel.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding + 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)
        
        postInfoLabel.anchor(titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: typeImageView.leftAnchor, topConstant: padding + 16, leftConstant: padding, bottomConstant: 0, rightConstant: padding, widthConstant: 0, heightConstant: 0)
        
        followUnfollowButton.anchor(nil, left: nil, bottom: bottomAnchor, right: marginGuide.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 4, rightConstant: -8, widthConstant: 55, heightConstant: 20)
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleFollowButtonStyle), name: UserProfileHeader.updateUserFollowingNotificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleGotoUserProfile() {
        guard let post = post else { return }
        let user = post.user
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        postContentController?.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    
    
    @objc func handleFollowUnfollow() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = post?.user.uid else { return }
        guard let user = post?.user else { return }
        
        if followUnfollowButton.titleLabel?.text == "Unfollow" {//unfollow
            post?.user.hasFollowed = false
            postContentController?.post?.user.hasFollowed = false
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
            post?.user.hasFollowed = true
            postContentController?.post?.user.hasFollowed = true
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
        guard let userId = post?.user.uid else { return }
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
    
    
    
    @objc private func handleFollowButtonStyle() {
        guard let post = post else { return }
        let hasFollowedOldState = post.user.hasFollowed
        self.post?.user.hasFollowed = !hasFollowedOldState
        postContentController?.post?.user.hasFollowed = !hasFollowedOldState
    }
    
}






