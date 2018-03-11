//
//  PostContentController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-06.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PostContentController: UITableViewController {
    
    var post: Post? {
        didSet {
            guard let postId = post?.postId else { return }
            Database.fetchPostMessagesPID(pid: postId) { (postMessages) in
                self.postMessages = postMessages
            }
        }
    }
    
    var postMessages = [PostMessage]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let headerCellId = "headerCellId"
    let messageCellId = "messageCellId"
    let cellSpacing: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = brightGray
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 125
        tableView.register(PostHeaderCell.self, forCellReuseIdentifier: headerCellId)
        tableView.register(PostMessageCell.self, forCellReuseIdentifier: messageCellId)
    }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return postMessages.count + 1
        }
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topIndexPath = IndexPath(row: 0, section: 0)
        let section = indexPath.section
        let row = indexPath.row
       
        if indexPath == topIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId, for: indexPath) as! PostHeaderCell
            cell.post = post
            return cell
        }
        
        if section == 0 && row >= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: messageCellId, for: indexPath) as! PostMessageCell
            cell.postMessage = postMessages[row - 1]
            return cell
        }
        
        let cell = UITableViewCell()
        return cell
    }


    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing + 5
    }
    
}







