//
//  WeekCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-26.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class dayCell: DatasourceCell {
    
    override var datasourceItem: Any? {
        didSet {
            //nameLabel.text = datasourceItem as? String
        }
    }
    
    override func setupViews() {
        backgroundColor = .white
    }
    
}
