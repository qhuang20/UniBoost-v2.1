//
//  LoadingView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-19.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class LoadingView: UIView {
    
    let gifView: UIImageView = {
        let imageView  = UIImageView()
        imageView.loadGif(name: "loading_rocket")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let gifViewFly: UIImageView = {
        let gif = UIImage.gif(name: "loading_rocket2")
        
        let imageView = UIImageView()
        imageView.animationImages = gif?.images
        imageView.animationDuration = gif!.duration
        imageView.animationRepeatCount = 2
        imageView.startAnimating()
        
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = brightGray

        addSubview(gifView)
        gifView.anchorCenterSuperview()
        gifView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 100)
        
        addSubview(gifViewFly)
        gifViewFly.anchorCenterXToSuperview()
        gifViewFly.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 200)
        gifViewFly.centerYAnchor.constraint(equalTo: gifView.superview!.centerYAnchor, constant: -50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

