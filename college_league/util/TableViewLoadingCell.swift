//
//  UITableViewLoadingCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class TableViewLoadingCell : UITableViewCell {
    
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
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let theEndLabel: UILabel = {
        let label = UILabel()
        label.text = "Ops, Reach The End"
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = brightGray
        isUserInteractionEnabled = false
        setupSubviews()
        activityIndicator.startAnimating()
    }

    private func setupSubviews() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(theEndLabel)
        
        activityIndicator.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: theEndLabel.topAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        theEndLabel.anchor(activityIndicator.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 0, heightConstant: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}




