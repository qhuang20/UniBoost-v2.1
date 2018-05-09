//
//  FriendCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-08.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class SearchUserCell: UICollectionViewCell {
    
    weak var searchUsersController: SearchUsersController?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(urlString: profileImageUrl)
            
            usernameLabel.text = user?.username
            
            if let userBio = user?.bio {
                userBioLabel.text = userBio
            } else {//reuse
                userBioLabel.text = ""
            }
            
            setupFollowUnfollowButton()
        }
    }
    
    private func setupFollowUnfollowButton() {
        guard let user = user else { return }
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let userId = user.uid
        
        if userId == currentLoggedInUserId {
            followUnfollowButton.isHidden = true
        } else {
            followUnfollowButton.isHidden = false
            user.hasFollowed ? setupUnfollowStyle() : setupFollowStyle()
        }
    }
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.backgroundColor = brightGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 50 / 2
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "UserName"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let userBioLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.lightGray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    lazy var followUnfollowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4.5
        button.addTarget(self, action: #selector(handleFollowUnfollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        addSubview(profileImageView)
        addSubview(usernameLabel)
        addSubview(userBioLabel)
        addSubview(followUnfollowButton)
        
        profileImageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        profileImageView.anchorCenterYToSuperview()
        
        usernameLabel.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 25)
        
        userBioLabel.anchor(usernameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: followUnfollowButton.leftAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 10, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        followUnfollowButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 70, heightConstant: 28)
        followUnfollowButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleFollowUnfollow() {
        guard let userId = user?.uid else { return }
        guard let user = user else { return }
        
        if followUnfollowButton.titleLabel?.text == "Unfollow" {//unfollow
            Database.unfollowUser(uid: userId)
        } else {//follow
            Database.followUser(uid: userId)
        }
        
        updateFollowButton(user: user)
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
    
    
    
    private func updateFollowButton(user: User) {
        let hasFollowedOldState = user.hasFollowed
        self.user?.hasFollowed = !hasFollowedOldState
        
        if let i = searchUsersController?.users.index(of: user) {
            searchUsersController?.users[i].hasFollowed = !hasFollowedOldState
        }
        if let j = searchUsersController?.filteredUsers.index(of: user) {
            searchUsersController?.filteredUsers[j].hasFollowed = !hasFollowedOldState
        }
    }
    
}








