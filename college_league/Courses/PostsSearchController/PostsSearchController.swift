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
    
    enum SortOption: String {
        case creationDate
        case likes
        case response
    }
    lazy var sortOption: String = SortOption.creationDate.rawValue
    
    enum SearchType: String {
        case all = "*"
        case question = "Question"
        case resource = "Resource"
        case bookForSale = "Book for Sale"
    }
    lazy var postType: String = SearchType.all.rawValue
    
    var isFinishedPaging = false
    var isPaging = true//fetchPostIds
    var queryStartingIndex = 0
    
    var previousSearchText = ""
    
    let cellId = "cellId"
    let cellSpacing: CGFloat = 1.5
    
    let filterContainerHeight: CGFloat = 36
    lazy var edgeInsetTopValue: CGFloat = filterContainerHeight
    let sortContainerHeight: CGFloat = 200
    
    let tableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar.getSearchBar()
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
                allLabel.text = "All Types"
                allLabel.font = UIFont.boldSystemFont(ofSize: 12.5)
                allLabel.textAlignment = .center
                allLabel.numberOfLines = 1
                allLabel.adjustsFontSizeToFitWidth = true
                v.backgroundColor = typeSelectedColor
                
                v.addSubview(allLabel)
                allLabel.anchor(v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, right: v.rightAnchor, topConstant: 0, leftConstant: 1.5, bottomConstant: 0, rightConstant: 1.5, widthConstant: 0, heightConstant: 0)
            } else {
                let imageView = UIImageView()
                imageView.image = UIImage(named: postTypes[i - 1])
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = UIColor.white
                imageView.contentMode = .scaleToFill
                
                v.addSubview(imageView)
                imageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 2, leftConstant: 0, bottomConstant: 2, rightConstant: 0, widthConstant: 20, heightConstant: 22)
                imageView.anchorCenterSuperview()
            }
            
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedType)))
            typeViews.append(v)
        }
        let sv = UIStackView(arrangedSubviews: typeViews)
        sv.distribution = .fillEqually
        sv.spacing = 8
        
        return sv
    }()
    
    lazy var filterImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "filter").withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.white
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSortContainer)))
        return iv
    }()
    
    lazy var dimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSortContainer)))
        dv.isHidden = true
        return dv
    }()
    
    let navBarDimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.isHidden = true
        return dv
    }()
    
    var sortContainerViewBottomAnchor: NSLayoutConstraint?
    
    let sortContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.clipsToBounds = true
        v.backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.text = "SORT POSTS BY: "
        titleLabel.font = UIFont.boldSystemFont(ofSize: 11.5)
        titleLabel.textColor = UIColor.gray
        v.addSubview(titleLabel)
        titleLabel.anchor(v.topAnchor, left: v.leftAnchor, bottom: nil, right: v.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        return v
    }()
    
    var sortOptionViews = [UIView]()
    let sortOptionsTexts = ["Most Recent", "Most Popular", "Most Response"]
    let sortSelectedColor = themeColor
    let sortUnSelectedColor = UIColor.lightGray
    
    lazy var sortStackView: UIStackView = {
        for i in 0...2 {
            let label = UILabel()
            label.textColor = sortUnSelectedColor
            if i == 0 {
                label.textColor = sortSelectedColor
            }
            label.text = sortOptionsTexts[i]
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedSortOption)))
            sortOptionViews.append(label)
        }
        let sv = UIStackView(arrangedSubviews: sortOptionViews)
        sv.distribution = .fillEqually
        sv.axis = .vertical
        sv.spacing = 12
        
        return sv
    }()
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        previousSearchText = searchBar.text ?? ""
        
        UIView.animate(withDuration: 0.2) {
            self.searchBar.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.showsCancelButton = true
        searchBar.text = previousSearchText
        enableCancelButton(searchBar: searchBar)
        
        UIView.animate(withDuration: 0.1) {
            self.searchBar.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.alpha = 1
    }
    
    override func viewDidLoad() {
        configureTableView()
        setupSearchBar()
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        view.addSubview(filterContainerView)
        filterContainerView.anchor(view.safeAreaTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: filterContainerHeight)
        
        filterContainerView.addSubview(typesStackView)
        typesStackView.anchor(filterContainerView.topAnchor, left: filterContainerView.leftAnchor, bottom: filterContainerView.bottomAnchor, right: filterContainerView.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 8, rightConstant: 72, widthConstant: 0, heightConstant: 0)
        
        filterContainerView.addSubview(filterImageView)
        filterImageView.anchor(filterContainerView.topAnchor, left: typesStackView.rightAnchor, bottom: filterContainerView.bottomAnchor, right: filterContainerView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 8, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(dimView)
        dimView.fillSuperview()
        
        self.navigationController?.navigationBar.addSubview(navBarDimView)
        navBarDimView.fillSuperview()

        view.addSubview(sortContainerView)
        sortContainerViewBottomAnchor = sortContainerView.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.safeAreaBottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: -sortContainerHeight, rightConstant: 8, widthConstant: 0, heightConstant: sortContainerHeight)[1]

        sortContainerView.addSubview(sortStackView)
        sortStackView.anchor(nil, left: sortContainerView.leftAnchor, bottom: sortContainerView.bottomAnchor, right: sortContainerView.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 36, rightConstant: 0, widthConstant: 0, heightConstant: 120)
        
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
        tableView.register(PostCell.self, forCellReuseIdentifier: cellId)
    }
    
    private func setupSearchBar() {
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter the keywords"
        searchBar.delegate = self

        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 1, rightConstant: 14, widthConstant: 0, heightConstant: 0)
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
    }
    
}






