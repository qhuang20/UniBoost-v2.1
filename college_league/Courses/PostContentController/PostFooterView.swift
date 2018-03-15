//
//  PostFooterView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-14.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit


class PostFooterView: UIView {
    
    let respondButtonColor = UIColor.init(r: 255, g: 244, b: 186)
    let buttonHeight: CGFloat = 32
    
    lazy var respondButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Respond", for: UIControlState.normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tintColor = themeColor
        button.backgroundColor = respondButtonColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.setImage(#imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = themeColor
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "bookmark_unselected").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(#imageLiteral(resourceName: "bookmark_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        button.tintColor = themeColor
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(respondButton)
        addSubview(bookmarkButton)
        addSubview(likeButton)

        respondButton.anchorCenterSuperview()
        respondButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 175, heightConstant: 0)
        
        bookmarkButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 22, widthConstant: buttonHeight, heightConstant: buttonHeight)
        bookmarkButton.anchorCenterYToSuperview()
        
        likeButton.anchor(nil, left: nil, bottom: nil, right: bookmarkButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: buttonHeight, heightConstant: buttonHeight)
        likeButton.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




