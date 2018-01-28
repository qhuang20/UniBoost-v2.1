//
//  CourseInfoCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class DaysHeader: DatasourceCell {
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.brown
        //addSubview(textLabel)
    }
    
}

class ColorsFooter: DatasourceCell {
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Show me more"
        label.font = UIFont.systemFont(ofSize: 15)
        //label.textColor = twitterBlue
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.brown
        //addSubview(textLabel)
    }
    
}

class InfoCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            //nameLabel.text = datasourceItem as? String
        }
    }
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(r: 130, g: 130, b: 130)
        return label
    }()
    
    override func setupViews() {
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = brightGray
       
        addSubview(textLabel)
        addSubview(separatorLineView)
        
        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        
        textLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 0)
    }
    
}



