//
//  CourseInfo.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseInfo: NSObject, NSCopying, NSCoding {
   
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
    
    //MARK: NSCoding
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("courseInfos")
    
    struct KeyName {
        static let days = "days"
        static let times = "times"
        static let title = "title"
        static let place = "place"
        static let note = "note"
        static let color = "color"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let days = aDecoder.decodeObject(forKey: KeyName.days) as! [Bool]
        let times = aDecoder.decodeObject(forKey: KeyName.times) as! [Int]
        let title = aDecoder.decodeObject(forKey: KeyName.title) as! String
        let place = aDecoder.decodeObject(forKey: KeyName.place) as! String
        let note = aDecoder.decodeObject(forKey: KeyName.note) as! String
        let color = aDecoder.decodeObject(forKey: KeyName.color) as! UIColor
 
        self.init(days: days, times: times, title: title, place: place, note: note, color: color)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(days, forKey: KeyName.days)
        aCoder.encode(times, forKey: KeyName.times)
        aCoder.encode(title, forKey: KeyName.title)
        aCoder.encode(place, forKey: KeyName.place)
        aCoder.encode(note, forKey: KeyName.note)
        aCoder.encode(color, forKey: KeyName.color)
    }
    
}







