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
            postInfos.removeAll()
            fetchPostInfos()
        }
    }
    
    var postInfos = [PostInfo]()
    var filteredPostInfos = [PostInfo]()
    
    var filterType: FilterType = FilterType.all
    var filteredTypePostInfos = [PostInfo]()
    
    enum FilterType: String {
        case all = "All"
        case boolForSale = "Book for Sale"
        case question = "Question"
        case resource = "Resource"
    }

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.fillSuperview()
        tableView.register(PostInfoCell.self, forCellReuseIdentifier: cellId)
        
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





