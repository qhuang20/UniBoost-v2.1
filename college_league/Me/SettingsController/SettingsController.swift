//
//  SettingsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class SettingCell: DatasourceCell {
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .yellow
        separatorLineView.isHidden = false
    }
    
}

class SettingsDatasource: Datasource {
    
    let words = ["Name", "Bio", "School", "Skill"]

    override func cellClasses() -> [DatasourceCell.Type] {
        return [SettingCell.self]
    }

    override func numberOfItems(_ section: Int) -> Int {
        return words.count
    }
    
    override func item(_ indexPath: IndexPath) -> Any? {
        return words[indexPath.item]
    }
    
}

class SettingsController: DatasourceController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        let editProfileDatasource = SettingsDatasource()
        self.datasource = editProfileDatasource
    }
    
}








