//
//  UserProfileHeader.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    private func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        profileImageView.loadImage(urlString: profileImageUrl)
    }
    
    let superBrightGray = UIColor.init(white: 0.96, alpha: 0.6)
    let numberAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
    let labelAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
    
    let userInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.lightGray
        iv.layer.cornerRadius = 80 / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var pointsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: numberAttributes)
        attributedText.append(NSAttributedString(string: "points", attributes: labelAttributes))
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: numberAttributes)
        attributedText.append(NSAttributedString(string: "followers", attributes: labelAttributes))
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: numberAttributes)
        attributedText.append(NSAttributedString(string: "following", attributes: labelAttributes))
        label.attributedText = attributedText
        
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        return button
    }()
    
    lazy var postsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.setTitle("posts", for: .normal)
        button.tintColor = UIColor.lightGray
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 0, bottom: 1, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.backgroundColor = superBrightGray
        return button
    }()
    
    lazy var responseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "response"), for: .normal)
        button.setTitle("response", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 4.6, left: 4, bottom: 4.6, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor.lightGray
        button.backgroundColor = superBrightGray
        return button
    }()
    
    lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.setTitle("bookmarks", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 6 , right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.tintColor = UIColor.lightGray
        button.backgroundColor = superBrightGray
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(userInfoLabel)
        addSubview(editProfileButton)

        profileImageView.anchor(topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 80)
        
        setupUserStatsView()

        editProfileButton.anchor(pointsLabel.bottomAnchor, left: pointsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, topConstant: 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
        
        setupBottomToolbar()
        
        userInfoLabel.anchor(profileImageView.bottomAnchor, left: leftAnchor, bottom: postsButton.topAnchor, right: rightAnchor, topConstant: 4, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 0)
    }
    
    private func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [pointsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 50)
    }
    
    private func setupBottomToolbar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [postsButton, responseButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 36)
        
        topDividerView.anchor(stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.2)
        
        bottomDividerView.anchor(stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
