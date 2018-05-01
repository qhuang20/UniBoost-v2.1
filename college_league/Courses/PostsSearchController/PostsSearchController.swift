//
//  PostsSearchController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-30.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import TRON

class PostsSearchController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let postTypes = ["Question", "Resource", "Book for Sale", "Other"]
    var course: Course?
    
    let tron = TRON(baseURL: "http://35.184.55.147//elasticsearch")
    
    var posts = [Post]()
    var postIds = [String]()
    
    lazy var postType = postTypes[0]
    
    var isFinishedPaging = false
    var isPaging = true//fetchPostIds
    var queryStartingIndex = 0
    
    var previousSearchText = ""
    
    let cellId = "cellId"
    let cellSpacing: CGFloat = 1.5
    
    let filterHeight: CGFloat = 36
    lazy var edgeInsetTopValue: CGFloat = filterHeight
    
    let tableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.layer.cornerRadius = 10
        sb.clipsToBounds = true
        sb.showsCancelButton = false
        sb.barTintColor = UIColor.white
        sb.returnKeyType = .done
        let textFieldInsideSearchBar = sb.value(forKey: "searchField") as? UITextField
        let button = textFieldInsideSearchBar?.rightView as? UIButton
        button?.tintColor = UIColor.black
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitlePositionAdjustment(UIOffset(horizontal: 4, vertical: 9), for: UIBarMetrics.default)
        
        let offset = UIOffset(horizontal: 0, vertical: -3)
        sb.searchTextPositionAdjustment = offset
        sb.setPositionAdjustment(offset, for: UISearchBarIcon.search)
        sb.setPositionAdjustment(offset, for: UISearchBarIcon.clear)
        sb.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 12)
        return sb
    }()
    
    let filterContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = themeColor
        return v
    }()
    
    var typeViews = [UIView]()
    let typeUnSelectedColor = UIColor(r: 255, g: 160, b: 110)
    let typeSelectedColor = UIColor(r: 255, g: 197, b: 37)
    
    lazy var typesStackView: UIStackView = {
        for i in 0...3 {
            let v = UIView()
            v.tag = i
            v.layer.cornerRadius = 12
            v.clipsToBounds = true
            v.backgroundColor = typeUnSelectedColor
            
            if i == 0 {
                let allLabel = UILabel()
                allLabel.textColor = UIColor.white
                allLabel.text = "All"
                allLabel.font = UIFont.boldSystemFont(ofSize: 16)
                allLabel.textAlignment = .center
                v.backgroundColor = typeSelectedColor
                
                v.addSubview(allLabel)
                allLabel.fillSuperview()
            } else {
                let imageView = UIImageView()
                imageView.image = UIImage(named: postTypes[i - 1])
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = UIColor.white
                imageView.contentMode = .scaleAspectFit
                
                v.addSubview(imageView)
                imageView.anchor(v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, right: v.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            }

            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedType)))
            typeViews.append(v)
        }
        let sv = UIStackView(arrangedSubviews: typeViews)
        sv.distribution = .fillEqually
        sv.spacing = 8
        
        return sv
    }()
    
    let filterImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filter").withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.white
        return iv
    }()
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        previousSearchText = searchBar.text ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.showsCancelButton = true
        searchBar.text = previousSearchText
        searchBar.placeholder = "Enter the keywords"
        searchBar.delegate = self
        enableCancelButton(searchBar: searchBar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.alpha = 1
    }
    
    override func viewDidLoad() {
        configureTableView()
        tableView.register(PostCell.self, forCellReuseIdentifier: cellId)
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        view.addSubview(filterContainerView)
        filterContainerView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: filterHeight)
        
        filterContainerView.addSubview(typesStackView)
        typesStackView.anchor(filterContainerView.topAnchor, left: filterContainerView.leftAnchor, bottom: filterContainerView.bottomAnchor, right: filterContainerView.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 8, rightConstant: 72, widthConstant: 0, heightConstant: 0)
        
        filterContainerView.addSubview(filterImageView)
        filterImageView.anchor(filterContainerView.topAnchor, left: typesStackView.rightAnchor, bottom: filterContainerView.bottomAnchor, right: filterContainerView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 8, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        searchBar.showsCancelButton = true
        searchBar.subviews.forEach { (subview) in
            if subview.isKind(of: UIButton.self) {
                subview.isUserInteractionEnabled = true
            }
        }
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
         searchBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 2, rightConstant: 20, widthConstant: 0, heightConstant: 0)

        fetchPostIds()
    }
    
    private func configureTableView() {
        tableView.backgroundColor = brightGray
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: edgeInsetTopValue, left: 0, bottom: 0, right: 0)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = 0
        }
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
        
        let postContentController = PostContentController(style: UITableViewStyle.grouped)
        postContentController.post = posts[indexPath.section]
        navigationController?.pushViewController(postContentController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = TableViewLoadingCell(style: .default, reuseIdentifier: "loading")
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PostCell
        if posts.count > indexPath.section {
            cell.post = posts[indexPath.section]
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
    
    
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == posts.count
    }
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
        
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging {
            paginatePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else { return 100 }
        return height
    }
    
    
    
    internal func showNoMatchesHintLabelIfNeeded() {
//        if filteredCourses.count == 0 {
//            hintLabel.isHidden = false
//            hintLabel.text = "Ops, no matches, try it again"///add report an issue button later
//        } else {
//            hintLabel.isHidden = true
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
    }
    
    private func enableCancelButton (searchBar : UISearchBar) {
        for view1 in searchBar.subviews {
            for view2 in view1.subviews {
                if view2.isKind(of: UIButton.self) {
                    let button = view2 as! UIButton
                    button.isEnabled = true
                    button.isUserInteractionEnabled = true
                }
            }
        }
    }
    
}






