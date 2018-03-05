//
//  DiscussionCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class DiscussionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    weak var discussionController: DiscussionController? {
        didSet {
            discussionController?.searchBar?.delegate = self
        }
    }

    var course: Course? {
        didSet {
            fetchPostInfos()
        }
    }
    
    var postInfos = [PostInfo]()
    var filteredPostInfos = [PostInfo]()

    let cellId = "cellId"
    let cellSpacing: CGFloat = 5
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: UITableViewStyle.plain)
        tv.backgroundColor = brightGray
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.rowHeight = UITableViewAutomaticDimension
        tv.estimatedRowHeight = 100
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.fillSuperview()
        tableView.register(PostInfoCell.self, forCellReuseIdentifier: cellId)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredPostInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostInfoCell
        cell.postInfo = filteredPostInfos[indexPath.section]
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





