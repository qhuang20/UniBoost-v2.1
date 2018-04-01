//
//  CommentCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class CommentCell: UICollectionViewCell {
    
    weak var commentsController: CommentsController?
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            let attributedText = NSMutableAttributedString(string: comment.user.username, attributes: attributesForUser)
            attributedText.append(NSAttributedString(string: " @" + comment.toUser.username, attributes: attributesForToUser))
            attributedText.appendNewLine()
            attributedText.append(NSAttributedString(string: comment.text, attributes: attributesForText))
            attributedText.append(NSAttributedString(string: "\n\n", attributes: attributesForNewLine))
            let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
            attributedText.append(NSAttributedString(string: "\(timeAgoDisplay)", attributes: attributesForTime))
            attributedText.append(NSAttributedString(string: "     Reply", attributes: attributesForReply))
            
            textView.attributedText = attributedText
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let attributesForUser = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]
    let attributesForToUser = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: themeColor]
    let attributesForText = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
    let attributesForTime = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.gray]
    let attributesForReply = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]
    let attributesForNewLine = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 6)]
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReply)))
        return textView
    }()
    
    let profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = brightGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        addSubview(textView)

        profileImageView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        textView.anchor(topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 4, leftConstant: 4, bottomConstant: 4, rightConstant: 4, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleReply() {
        commentsController?.commentTextView.placeholderLabel.text = "@\(comment?.user.username ?? "")"
        commentsController?.toUser = comment?.user
        commentsController?.commentTextView.becomeFirstResponder()
    }
    
}












