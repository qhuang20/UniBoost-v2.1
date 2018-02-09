//
//  CourseInfo.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseInfo: NSObject, NSCopying {
   
    @objc var days: [Bool]//just for AddCourseController
    
    @objc var times: [Int]
    @objc var title: String
    @objc var place: String
    @objc var note: String
    @objc var color: UIColor
    
    init(days: [Bool], times: [Int], title: String, place: String, note: String, color: UIColor) {
        self.days = days
        self.times = times
        self.title = title
        self.place = place
        self.note = note
        self.color = color
    }
    
    override init() {
        self.times = [60 * 9, 60 * 10]
        self.days = [true, false, false, false, false]
        self.title = ""
        self.place = ""
        self.note = ""
        self.color = UIColor.orange
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return CourseInfo(days: days, times: times, title: title, place: place, note: note, color: color)
    }
    
}
