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
            handleRefresh()///
        }
    }
    
    var posts = [Post]()
    var filteredPosts = [Post]()
    var isFinishedPaging = false
    var isPaging = false

    let cellId = "cellId"
    let cellSpacing: CGFloat = 1.5
    
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
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        return aiv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        rc.tintColor = themeColor
        return rc
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.backgroundView = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        addSubview(tableView)
        tableView.fillSuperview()
        tableView.register(PostCell.self, forCellReuseIdentifier: cellId)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        discussionController?.searchBar?.isHidden = true
        discussionController?.searchBar?.resignFirstResponder()
        
        let navigationController = discussionController?.navigationController
        let postContentController = PostContentController()
        postContentController.post = filteredPosts[indexPath.section]
        
        navigationController?.pushViewController(postContentController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == self.filteredPosts.count - 1 && !isFinishedPaging && !isPaging {
            activityIndicatorView.startAnimating()
            paginatePosts()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostCell
        if filteredPosts.count > indexPath.section {
            cell.post = filteredPosts[indexPath.section]
        }
        
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





