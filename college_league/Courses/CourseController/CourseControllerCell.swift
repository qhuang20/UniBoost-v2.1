//
//  CourseControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseControllerCell: UICollectionViewCell {
    
    var course: Course? {
        didSet {
            setupAttributedTitle()
        }
    }
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 25)]
    let attributesForDescription = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12.5), NSAttributedStringKey.foregroundColor: UIColor.lightGray]

    private func setupAttributedTitle() {
        guard let course = course else { return }
        
        let attributedText = NSMutableAttributedString(string: course.name, attributes: attributesForTitle)
        attributedText.appendNewLine()
        let attributedCourseNumber =  NSAttributedString(string: course.number, attributes: attributesForTitle)
        attributedText.append(attributedCourseNumber)
        attributedText.appendNewLine()
        
        let attributedCourseDescription = NSAttributedString(string: "• " + course.description, attributes: attributesForDescription)
        attributedText.append(attributedCourseDescription)
        
        courseInfoLabel.attributedText = attributedText
    }
   
    lazy var courseInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
     
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        backgroundColor = UIColor.white
        
        addSubview(courseInfoLabel)
        
        courseInfoLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
