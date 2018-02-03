//
//  DayCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class DayCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            dayCourses = datasourceItem as! [CourseInfo]
        }
    }
    
    var courseViews: [CourseView] = []

    var dayCourses: [CourseInfo] = [] {
        didSet {
            //clear all the state
            for view in courseViews {
                view.removeFromSuperview()
            }
            courseViews = []
            
            for course in dayCourses {
                courseViews.append(CourseView(courseInfo: course))
            }
            updateUI()
        }
    }
    
    private func updateUI() {
        
        for courseView in courseViews {
            let cellHeight = frame.height
            let startMinutes = courseView.courseInfo.times[0]
            let endMinutes = courseView.courseInfo.times[1]
            let minutesInterval = endMinutes - startMinutes
            
            let courseStackViewHeight = CGFloat(minutesInterval) / (12 * 60) * cellHeight
            let courseTopDistance = (CGFloat(startMinutes) - 8 * 60) * cellHeight / (12 * 60)
            
            //the view will render all its subviews after the view is created
            addSubview(courseView)//state changed!!!! (add to self subview list)
            
            courseView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: courseTopDistance, leftConstant: 1, bottomConstant: 0, rightConstant: 1, widthConstant: 0, heightConstant: courseStackViewHeight)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        self.backgroundColor = .white
    }
    
}




