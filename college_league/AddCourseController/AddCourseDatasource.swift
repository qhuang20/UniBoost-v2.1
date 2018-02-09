//
//  AddCourseDatasource.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class AddCourseDatasource: Datasource {
    
    var oldCourseViewColor: UIColor?
    var editCourseBoolArray: [Bool]?
    
    override func headerItem(_ section: Int) -> Any? {
        return editCourseBoolArray
    }
    
    override func footerItem(_ section: Int) -> Any? {
        return oldCourseViewColor
    }
    
    
    
    override func headerClasses() -> [DatasourceCell.Type]? {
        return [DaysHeader.self]
    }
    
    override func footerClasses() -> [DatasourceCell.Type]? {
        return [ColorsFooter.self]
    }
    
    override func cellClasses() -> [DatasourceCell.Type] {
        return [InfoCell.self]
    }
    
    
    
    override func numberOfItems(_ section: Int) -> Int {
        return 4
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {//to Cell
        return nil
    }
    
}

