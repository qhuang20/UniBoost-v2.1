//
//  FeedCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class PostInfoCell: UITableViewCell {
    
    var postInfo: PostInfo? {
        didSet {
            guard let postInfo = postInfo else { return }
            let user = postInfo.user

            titleLabel.text = postInfo.title
            typeImageView.image = UIImage(named: postInfo.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
        }
    }
    
    override var selectionStyle: UITableViewCellSelectionStyle {
        get { return UITableViewCellSelectionStyle.default }
        set {}
    }
    
    let profileImageWidth: CGFloat = 36
    let typeImageWidth: CGFloat = 25
    let padding: CGFloat = 8
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
    
    lazy var postInfoLabel: UILabel = {
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(typeImageView)
        contentView.addSubview(postInfoLabel)
        
        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageView.anchor(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)

        typeImageView.anchor(titleLabel.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)

        postInfoLabel.anchor(titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: typeImageView.leftAnchor, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





