//
//  UserPostResponseCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-13.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class UserPostResponseCell: UserPostCell {
    
    var response: Response? {
        didSet {
            guard let post = response?.post else { return }
            thumbnailImageView.image = nil
            thumbnailImageView.backgroundColor = brightGray
            let user = post.user
            
            titleLabel.text = post.title
            typeImageView.image = UIImage(named: post.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            
            if let thumbnailImageUrl = post.thumbnailImageUrl {
                let imageHeight = post.thumbnailImageHeight!
                if imageHeight > 250 {
                    thumbnailImageView.contentMode = .scaleAspectFit
                } else {
                    thumbnailImageView.contentMode = .scaleAspectFill
                }
                thumbnailImageView.loadImage(urlString: thumbnailImageUrl, completion: nil)
                userInfoLabelTopAnchor?.constant = 8
            } else {
                thumbnailImageView.image = nil
                thumbnailImageView.backgroundColor = UIColor.white
                userInfoLabelTopAnchor?.constant = 16
            }
            
            setupAttributedCaption()
            
            
            
            guard let response = response else { return }
            let currentUser = response.user
            
            myProfileImageView.loadImage(urlString: currentUser.profileImageUrl, completion: nil)
            setupAttributedResponseInfoLabel()
        }
    }
    
    internal override func setupAttributedCaption() {
        guard let post = response?.post else { return }
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
        postLabel.attributedText = attributedText
    }
    
    private func setupAttributedResponseInfoLabel() {
        guard let response = self.response else { return }
        let userBio = response.user.bio ?? ""
        
        var attributedText = NSMutableAttributedString(string: "\(response.user.username)", attributes: attributesForUserInfo)
        if userBio.count > 0 {
            attributedText = NSMutableAttributedString(string: "\(response.user.username): \(userBio)", attributes: attributesForUserInfo)
        }
        
        attributedText.appendNewLine()
        
        let timeAgoDisplay = response.creationDate.timeAgoDisplay()
        let responseLikes = response.likes
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplay) • \(responseLikes) likes", attributes: attributesForTime))
        
        attributedText.setLineSpacing(8)
        responseInfoLabel.attributedText = attributedText
    }
    
    lazy var responseInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "SAMPLE TEXT"
        return label
    }()
    
    lazy var myProfileImageView: CachedImageView = {
        let iv = CachedImageView(cornerRadius: profileImageWidth / 2)
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = brightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.removeFromSuperview()//to remove super constraint
        thumbnailImageView.removeFromSuperview()
        postLabel.removeFromSuperview()
        let marginGuide = self.layoutMarginsGuide
        addSubview(titleLabel)
        addSubview(postLabel)
        addSubview(myProfileImageView)
        addSubview(responseInfoLabel)

        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        profileImageView.anchor(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        
        typeImageView.anchor(titleLabel.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: padding, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)
        
        postLabel.anchor(titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: typeImageView.leftAnchor, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: padding, widthConstant: 0, heightConstant: 0)
        postLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        
        myProfileImageView.anchor(postLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding + 4, leftConstant: padding + 8, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth - 4, heightConstant: profileImageWidth - 4)

        responseInfoLabel.anchor(postLabel.bottomAnchor, left: myProfileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: marginGuide.rightAnchor, topConstant: 2, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




