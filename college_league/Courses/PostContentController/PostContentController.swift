//
//  PostContentController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-06.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class PostContentController: UITableViewController {
    
    var post: Post?
    let cellId = "cellId"
    let cellSpacing: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = brightGray
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.register(PostContentCell.self, forCellReuseIdentifier: cellId)
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.section
       
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostContentCell
            cell.post = post
            cell.postContentController = self
            return cell
        }
        
        let cell = UITableViewCell()
        
        return cell
    }
    


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }
    
}

extension UITableViewController {
    
    func updateRowHeight(cell: UITableViewCell) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
}



