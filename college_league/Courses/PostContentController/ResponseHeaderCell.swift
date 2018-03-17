//
//  ResponseHeaderCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class ResponseHeaderCell: UITableViewCell {
    
    weak var postContentController: PostContentController?
    
    var response: Response? {
        didSet {
            guard let response = response else { return }
            let user = response.user
            
            profileImageView.loadImage(urlString: user.profileImageUrl, completion: nil)
            setupAttributedCaption()
        }
    }
    
    private func setupAttributedCaption() {
        guard let response = self.response else { return }
        
        let attributedText = NSMutableAttributedString(string: "\(response.user.username): A big boss, hhhhhh", attributes: attributesForUserInfo)
        
        attributedText.appendNewLine()
        
        let timeAgoDisplay = response.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplay)", attributes: attributesForTime))
        
        attributedText.setLineSpacing(8)
        responseInfoLabel.attributedText = attributedText
    }
    
    let profileImageWidth: CGFloat = 44
    let padding: CGFloat = 8
    let attributesForUserInfo = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
    let attributesForTime = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]
    
    lazy var profileImageView: CachedImageView = {
        let iv = CachedImageView(cornerRadius: profileImageWidth / 2)
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGotoUserProfile)))
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = brightGray
        return iv
    }()
    
    lazy var responseInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGotoUserProfile)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        let marginGuide = contentView.layoutMarginsGuide
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(responseInfoLabel)
        
        profileImageView.anchor(marginGuide.topAnchor, left: marginGuide.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: profileImageWidth, heightConstant: profileImageWidth)
        responseInfoLabel.anchor(marginGuide.topAnchor, left: profileImageView.rightAnchor, bottom: marginGuide.bottomAnchor, right: marginGuide.rightAnchor, topConstant: 0, leftConstant: padding, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleGotoUserProfile() {
        guard let response = response else { return }
        let user = response.user
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        postContentController?.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
}





