//
//  FeedCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class PostCell: UITableViewCell {
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            let user = post.user

            titleLabel.text = post.title
            typeImageView.image = UIImage(named: post.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            
            if let thumbnailImageUrl = post.thumbnailImageUrl {
                let imageHeight = post.thumbnailImageHeight!
                
                if imageHeight > 376 {
                    thumbnailImageViewHeightAnchor?.constant = 376
                    thumbnailImageView.contentMode = .scaleAspectFit
                    thumbnailImageView.backgroundColor = UIColor.white
                } else {
                    thumbnailImageViewHeightAnchor?.constant = imageHeight
                    thumbnailImageView.contentMode = .scaleAspectFill
                    thumbnailImageView.backgroundColor = brightGray
                }
                thumbnailImageView.loadImage(urlString: thumbnailImageUrl, completion: nil)
                
            } else {
                thumbnailImageViewHeightAnchor?.constant = 0
            }
        }
    }
    
    var thumbnailImageViewHeightAnchor: NSLayoutConstraint?
    
    let profileImageWidth: CGFloat = 36
    let typeImageWidth: CGFloat = 25
    let padding: CGFloat = 16
    let attributesForUserInfo = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
    let attributesTimeCommentLike = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.5), NSAttributedStringKey.foregroundColor: UIColor.gray]
    
    let typeImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor.lightGray
        return iv
    }()
    
    lazy var profileImageView: CachedImageView = {
        let iv = CachedImageView(cornerRadius: profileImageWidth / 2, emptyImage: nil)
        iv.backgroundColor = brightGray
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        label.text = "Sample Title"
        return label
    }()
    
    lazy var postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: "Jeff, is a big boss in the world", attributes: attributesForUserInfo)
        attributedText.setLineSpacing(8)
        let attributedOtherInfo = NSAttributedString(string: "Mar 28, 2017 • 10 comments, 12000 likes", attributes: attributesTimeCommentLike)
        attributedText.appendNewLine()
        attributedText.append(attributedOtherInfo)

        label.attributedText = attributedText
        return label
    }()
    
    let thumbnailImageView: CachedImageView = {
        let imageView = CachedImageView(cornerRadius: 8, emptyImage: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = brightGray
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(typeImageView)
        contentView.addSubview(postLabel)
        contentView.addSubview(thumbnailImageView)
        
        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        thumbnailImageViewHeightAnchor = thumbnailImageView.anchorWithReturnAnchors(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.1)[3]
        
        profileImageView.anchor(thumbnailImageView.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)

        typeImageView.anchor(thumbnailImageView.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)

        postLabel.anchor(thumbnailImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: typeImageView.leftAnchor, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






