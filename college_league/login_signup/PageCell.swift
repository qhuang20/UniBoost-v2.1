//
//  PageCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            guard let page = page else { return }
            imageView.image = page.image
            
            messasgeLabel.text = page.message
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UniBoost"
        label.font = UIFont(name: "Noteworthy-Bold", size: 45)
        label.textColor = lightThemeColor
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "page1")
        iv.clipsToBounds = true
        return iv
    }()
    
    let messasgeLabel: UILabel = {
        let label = UILabel()
        label.text = "Sharing is Caring"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.fillSuperview()
        
        imageView.addSubview(messasgeLabel)
        messasgeLabel.anchorCenterXToSuperview()
        messasgeLabel.anchorCenterYToSuperview(constant: -50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





