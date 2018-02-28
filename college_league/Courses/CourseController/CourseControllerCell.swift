//
//  CourseControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseControllerCell: UICollectionViewCell {
    
    var courseName = "Math"
    var courseNumber = "1127"
    var courseDescription = "Linear Algebra and website development"
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 25)]
    let attributesForDescription = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.lightGray]

    lazy var courseNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        let attributedText = NSMutableAttributedString(string: courseName, attributes: attributesForTitle)
        attributedText.appendNewLine()
        let attributedCourseNumber =  NSAttributedString(string: courseNumber, attributes: attributesForTitle)
        attributedText.append(attributedCourseNumber)
        attributedText.appendNewLine()
        
        let attributedCourseDescription = NSAttributedString(string: "• " + courseDescription, attributes: attributesForDescription)
        attributedText.append(attributedCourseDescription)

        label.attributedText = attributedText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        backgroundColor = UIColor.white
        
        addSubview(courseNameLabel)
        
        courseNameLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
