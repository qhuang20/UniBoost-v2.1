//
//  TimetableDatasource.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-26.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class TimetableDatasource: Datasource {
    
    var weekCourses: [[CourseInfo]] = [[], [], [], [], []] {
        didSet{
            saveWeekCourses()
        }
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [DayCell.self]
    }
    
    override func numberOfItems(_ section: Int) -> Int {
        return weekdays.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {//to Cell
        return weekCourses[indexPath.item]
    }
    
    
    
    //MARK: Save and Load
    public func saveWeekCourses() {
        NSKeyedArchiver.archiveRootObject(weekCourses, toFile: CourseInfo.archiveURL.path)
    }
    
    public func loadWeekCourses() -> [[CourseInfo]]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: CourseInfo.archiveURL.path) as?  [[CourseInfo]]
    }
    
}
