//
//  CollectionViewLoadingCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CollectionViewLoadingCell: UICollectionViewCell {
    
    var isTheEnd: Bool = false {
        didSet {
            if isTheEnd {
                activityIndicator.stopAnimating()
                theEndLabel.isHidden = false
            } else {
                activityIndicator.startAnimating()
                theEndLabel.isHidden = true
            }
        }
    }
    
    let theEndLabel: UILabel = {
        let label = UILabel()
        label.text = "no more posts"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    let pullToRefreshLabel: UILabel = {
        let label = UILabel()
        label.text = "Pull to Load More"
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13.5)
        label.isHidden = true
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        isUserInteractionEnabled = false
        setupSubviews()
        activityIndicator.startAnimating()
    }
    
    
    
    private func setupSubviews() {
        addSubview(activityIndicator)
        addSubview(pullToRefreshLabel)
        addSubview(theEndLabel)
        
        activityIndicator.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        pullToRefreshLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        theEndLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


