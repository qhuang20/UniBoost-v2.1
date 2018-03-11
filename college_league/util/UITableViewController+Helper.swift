//
//  UITableView+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-10.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UITableViewController {
    
    func updateRowHeight(cell: UITableViewCell) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
}
