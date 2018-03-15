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
            filteredTypePosts.removeAll()
            posts.removeAll()
            fetchPosts()
        }
    }
    
    var posts = [Post]()
    var filteredPosts = [Post]()
    
    var filterType: FilterType = FilterType.all
    var filteredTypePosts = [Post]()
    
    enum FilterType: String {
        case all = "All"
        case boolForSale = "Book for Sale"
        case question = "Question"
        case resource = "Resource"
    }

    let cellId = "cellId"
    let cellSpacing: CGFloat = 3
    
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
    
    var windowView: UIView?
    var typesViewBottomAnchor: NSLayoutConstraint?
    
    lazy var dimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDimView)))
        return dv
    }()
    
    lazy var typesView: UIStackView = {
        var buttons = [UIButton]()
        
        for type in postTypes {
            let button = UIButton()
            button.backgroundColor = UIColor.white
            button.adjustsImageWhenHighlighted = false
            let image = UIImage(named: type)?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.setTitle(type, for: .normal)
            if type == postTypes[3] {
                button.setTitle(FilterType.all.rawValue, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22.5)
                button.isSelected = true
            }
            
            let space: CGFloat = -35
            if type == postTypes[0] {
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30 + space, bottom: 0, right: 0)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20 + space, bottom: 0, right: 0)
            } else if type == postTypes[1] {
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -27 + space, bottom: 0, right: 0)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25 + space, bottom: 0, right: 0)
            } else if type == postTypes[2] {
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5 + space, bottom: 0, right: 0)
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 56 + space, bottom: 0, right: 0)
            } else {
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            
            button.setTitleColor(themeColor, for: .selected)
            button.setTitleColor(UIColor.lightGray, for: .normal)
            button.tintColor = UIColor.lightGray
            button.addTarget(self, action: #selector(handleFilterType), for: .touchUpInside)
            buttons.append(button)
        }
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.alignment = UIStackViewAlignment.fill
        sv.distribution = .fillEqually
        sv.axis = UILayoutConstraintAxis.vertical
        sv.spacing = -5
        return sv
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
        
        windowView = UIApplication.shared.keyWindow
        windowView?.addSubview(dimView)
        windowView?.addSubview(typesView)
        
        dimView.fillSuperview()
        dimView.alpha = 0
        typesViewBottomAnchor = typesView.anchorWithReturnAnchors(nil, left: windowView?.leftAnchor, bottom: windowView?.safeAreaLayoutGuide.bottomAnchor, right: windowView?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 175)[1]
        typesViewBottomAnchor?.constant = 175
    }
    
    deinit {
        dimView.removeFromSuperview()
        typesView.removeFromSuperview()
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
    
    func reload(tableView: UITableView) {//fix jumping issue
        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)
        
        let indexPath = IndexPath(row: 0, section: 0)
        if (filteredPosts.count > 0) {
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)///fix position bug?
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





