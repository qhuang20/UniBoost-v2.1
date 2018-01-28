//
//  Timetable+handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension TimetableController {
    
    @objc func addNewCourse() {
        let addCourseController = AddCourseController()
        navigationController?.pushViewController(addCourseController, animated: true)
    }
    
}
