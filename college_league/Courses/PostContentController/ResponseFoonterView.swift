//
//  ResponseFoonterView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class ResponseFoonterView: UIView {
    
    weak var postContentController: PostContentController?
    var response: Response?
    
    let buttonHeight: CGFloat = 32
    
    let likeButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysTemplate), for: UIControlState.normal)
        button.setImage(#imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = themeColor
        return button
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.text = "1002 likes"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = themeColor
        label.numberOfLines = 1
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(#imageLiteral(resourceName: "comment_selected").withRenderingMode(.alwaysTemplate), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        button.tintColor = themeColor
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(commentButton)
        addSubview(likeButton)
        addSubview(likesLabel)
        
        commentButton.anchor(nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 28, widthConstant: buttonHeight - 2, heightConstant: buttonHeight + 4)
        commentButton.anchorCenterYToSuperview()
        
        likeButton.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 22, bottomConstant: 0, rightConstant: 0, widthConstant: buttonHeight, heightConstant: buttonHeight)
        likeButton.anchorCenterYToSuperview()
        
        likesLabel.anchor(nil, left: likeButton.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: buttonHeight)
        likesLabel.anchorCenterYToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleComment() {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.response = response
        postContentController?.navigationController?.pushViewController(commentsController, animated: true)
    }
    
}





