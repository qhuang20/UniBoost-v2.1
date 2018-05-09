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
        guard let userId = response?.user.uid else { return }
        guard let user = response?.user else { return }
        
        checkAllUsersToUpdateFollowButton(user: user)
        
        if followUnfollowButton.titleLabel?.text == "Unfollow" {//unfollow
            Database.unfollowUser(uid: userId)
        } else {//follow
            Database.followUser(uid: userId)
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





