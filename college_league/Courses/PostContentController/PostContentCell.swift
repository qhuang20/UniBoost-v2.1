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
import Gzip

class PostContentCell: UITableViewCell {
    
    weak var postContentController: PostContentController?
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            let user = post.user
            
            titleLabel.text = post.title
            typeImageView.image = UIImage(named: post.type)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            
            let rtfdUrl = post.rtfdUrl
            guard let url = URL(string: rtfdUrl) else { return }
            
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    let decompressedData: Data
                    if data!.isGzipped {
                        decompressedData = try! data!.gunzipped()
                    } else {
                        decompressedData = data!
                    }
                    
                    let documentAttributes = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtfd]
                    let attributedText = try! NSAttributedString(data: decompressedData, options: documentAttributes, documentAttributes: nil)
                    self.postTextView.attributedText = attributedText
                    self.postContentController?.updateRowHeight(cell: self)
                }
            }).resume()
        }
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
    
    lazy var postTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.isEditable = false
        tv.text = "Loading..."
        tv.textColor = UIColor.lightGray
        return tv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(typeImageView)
        contentView.addSubview(postLabel)
        contentView.addSubview(postTextView)
        
        titleLabel.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        profileImageView.anchor(titleLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        
        typeImageView.anchor(titleLabel.bottomAnchor, left: nil, bottom: nil, right: marginGuide.rightAnchor, topConstant: padding, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: typeImageWidth, heightConstant: typeImageWidth + 4)
        
        postLabel.anchor(titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: typeImageView.leftAnchor, topConstant: padding, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        postTextView.anchor(postLabel.bottomAnchor, left: marginGuide.leftAnchor, bottom: marginGuide.bottomAnchor, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



