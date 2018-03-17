//
//  UserPostCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class UserPostCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            thumbnailImageView.image = nil
            thumbnailImageView.backgroundColor = UIColor.white
            guard let post = post else { return }
            let user = post.user
            
            titleLabel.text = post.title
            typeImageView.image = UIImage(named: post.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            
            if let thumbnailImageUrl = post.thumbnailImageUrl {
                let imageHeight = post.thumbnailImageHeight!
                if imageHeight > 250 {
                    thumbnailImageView.contentMode = .scaleAspectFit
                    thumbnailImageView.backgroundColor = UIColor.white
                } else {
                    thumbnailImageView.contentMode = .scaleAspectFill
                    thumbnailImageView.backgroundColor = brightGray
                }
                thumbnailImageView.loadImage(urlString: thumbnailImageUrl, completion: nil)
            } else {
                thumbnailImageView.image = nil
                thumbnailImageView.backgroundColor = UIColor.white
            }
            
            setupAttributedCaption()
        }
    }
    
    private func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(post.user.username): A big boss", attributes: attributesForUserInfo)
        
        attributedText.appendNewLine()
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplay) • 10 response • 12000 likes", attributes: attributesTimeResponseLike))
        
        attributedText.setLineSpacing(8)
        postLabel.attributedText = attributedText
    }
    
    let profileImageWidth: CGFloat = 36
    let typeImageWidth: CGFloat = 25
    let padding: CGFloat = 8
    let cellSpacing: CGFloat = 1
    let attributesForUserInfo = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
    let attributesTimeResponseLike = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]
    
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
        return label
    }()
    
    let thumbnailImageView: CachedImageView = {
        let imageView = CachedImageView(cornerRadius: 4, emptyImage: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = brightGray
        return imageView
    }()
    
    open let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = brightGray
        return lineView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let marginGuide = self.layoutMarginsGuide
        
        addSubview(titleLabel)
        addSubview(profileImageView)
        addSubview(typeImageView)
        addSubview(postLabel)
        addSubview(thumbnailImageView)
        addSubview(separatorLineView)
        
        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.vertical)
        
        thumbnailImageView.anchor(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageView.anchor(thumbnailImageView.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        
        typeImageView.anchor(thumbnailImageView.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: padding, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)
        
        postLabel.anchor(thumbnailImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: typeImageView.leftAnchor, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        postLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: UILayoutConstraintAxis.vertical)
        
        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: cellSpacing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







