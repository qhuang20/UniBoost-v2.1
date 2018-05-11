//
//  FriendsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-08.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class HeaderView: UICollectionViewCell {
    
    var suggestedLabel: UILabel = {
        let label = UILabel()
        label.text = "Most Likes"
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        return indicator
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(suggestedLabel)
        addSubview(indicator)
        
        suggestedLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 0)
        indicator.anchor(topAnchor, left: suggestedLabel.rightAnchor, bottom: bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SearchUsersController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    static let refreshHomeNotificationName = NSNotification.Name(rawValue: "refreshHome")
    
    var filteredUsers = [User]()
    var users = [User]()
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    let headerViewId = "headerViewId"
    
    var isSearching: Bool = false//suggestedLabel, indicator
    var isSearchTextEmpty: Bool = false//suggestedLabel, indicator
    
    var isFinishedSearching: Bool = false//hide header
    var isNoResultsFound: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar.getSearchBar()
        return sb
    }()
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: SearchUsersController.refreshHomeNotificationName, object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.searchBar.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1) {
            self.searchBar.alpha = 1
        }
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Find Friends"
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        enableCancelButton(searchBar: searchBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 1, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFollowButtonStyle), name: UserProfileHeader.updateUserFollowingNotificationName, object: nil)
        
        fetchSchoolUsers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        
        collectionView?.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewId)
        collectionView?.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: loadingCellId)
        collectionView?.register(SearchUserCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 50
        
        if isFinishedSearching && !isNoResultsFound {
            height = 0
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerViewId, for: indexPath) as! HeaderView
        
        if isSearchTextEmpty {
            header.suggestedLabel.text = "Most Likes"
            header.indicator.stopAnimating()
        } else if isSearching {
            header.suggestedLabel.text = "Searching"
            header.indicator.startAnimating()
        } else if isFinishedSearching && isNoResultsFound {
            header.suggestedLabel.text = " No results"
            header.indicator.stopAnimating()
        }
        
        return header
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
        
        let user = filteredUsers[indexPath.item]
        
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchUserCell
        cell.user = filteredUsers[indexPath.item]
        cell.searchUsersController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
    }
    
}






