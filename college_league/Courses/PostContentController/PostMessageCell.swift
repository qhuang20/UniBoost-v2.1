//
//  PostMessageCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-10.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class PostMessageCell: UITableViewCell {
    
    var postMessage: PostMessage? {
        didSet {
            guard let postMessage = postMessage else { return }
            
            if let thumbnailImageUrl = postMessage.thumbnailUrl {
                postTextViewHeightAnchor?.constant = 0
                thumbnailImageViewHeightAnchor?.constant = postMessage.imageHeight!
                activityIndicatorView.startAnimating()
                thumbnailImageView.loadImage(urlString: thumbnailImageUrl, completion: {
                    self.activityIndicatorView.stopAnimating()
                })
                
                postTextView.text = nil
                thumbnailImageView.isHidden = false
                postTextView.isHidden = true
                
            } else {
                
                postTextViewHeightAnchor?.constant = estimateHeightFor(text: postMessage.text ?? "") + 18
                thumbnailImageViewHeightAnchor?.constant = 0
                postTextView.text = postMessage.text

                thumbnailImageView.image = nil
                thumbnailImageView.isHidden = true
                postTextView.isHidden = false
            }
        }
    }
    
    var thumbnailImageViewHeightAnchor: NSLayoutConstraint?
    var postTextViewHeightAnchor: NSLayoutConstraint?
    
    lazy var postTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isScrollEnabled = false
        tv.isSelectable = false
        tv.isEditable = false
        tv.text = "Sample Sample Sample"
        return tv
    }()
    
    lazy var thumbnailImageView: CachedImageView = {
        let imageView = CachedImageView(cornerRadius: 8, tapCallback: {
            print("tap")
        })
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = brightGray
        return imageView
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        return aiv
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(postTextView)
        thumbnailImageView.addSubview(activityIndicatorView)
        
        thumbnailImageViewHeightAnchor = thumbnailImageView.anchorWithReturnAnchors(contentView.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: marginGuide.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 12, rightConstant: 0, widthConstant: 0, heightConstant: 0.1)[3]
        postTextViewHeightAnchor = postTextView.anchorWithReturnAnchors(thumbnailImageView.bottomAnchor, left: marginGuide.leftAnchor, bottom: contentView.bottomAnchor, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: -4, bottomConstant: 0, rightConstant: -4, widthConstant: 0, heightConstant: 0.1)[4]
        activityIndicatorView.anchorCenterSuperview()
    }
    
    private func estimateHeightFor(text: String) -> CGFloat {
        let size = CGSize(width: 374, height: 1000)///
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        return rect.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













