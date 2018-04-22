//
//  HomeController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-13.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var postIds = [String]()
    
    var posts = [Post]()
    var isFinishedPaging = false
    var isPaging = true//fetchFollowingUserPostIds
    var queryStartingIndex = 0
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        rc.tintColor = themeColor
        return rc
    }()
    
    lazy var getStartedButton: UIButton = {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.backgroundColor = themeColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.isHidden = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        configureNavigationBar()
        getStartedButton.addTarget(self, action: #selector(handleAddFriends), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: UserProfileHeader.updateUserFollowingNotificationName, object: nil)
        
        view.addSubview(getStartedButton)
        getStartedButton.setTitle("Follow Your Friends", for: .normal)
        
        getStartedButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 42)
        getStartedButton.anchorCenterXToSuperview()
        
        fetchFollowingUserPostIds()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func configureNavigationBar() {
        navigationItem.title = "Home"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "timetable").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleTimetable))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add_friends").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleAddFriends))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    internal func configureCollectionVeiw() {
        collectionView?.backgroundView = refreshControl
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: loadingCellId)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = posts.count
        return count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.theEndLabel.isHidden = false
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if posts.count > indexPath.item {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: view.frame.width, height: 100)
        }
        
        let width = view.frame.width
        let userInfo = posts[indexPath.item].user.username + (posts[indexPath.item].user.bio ?? "")
        var height: CGFloat = estimateHeightForUserInfo(text: userInfo) + 50 + 14
        
        if let imageHeight = posts[indexPath.item].thumbnailImageHeight {
            if imageHeight > 370 { height += 370 }
            else { height += imageHeight }
        }
        
        let postTitleHeight = estimateHeightForPostTitle(text: posts[indexPath.item].title)
        height += postTitleHeight
        
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging {
            paginatePosts()
        }
    }
    
    
    
    internal func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == posts.count
    }
    
    private func estimateHeightForPostTitle(text: String) -> CGFloat {
        let attributesForPostTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22)]
        let size = CGSize(width: view.frame.width - 20 - 20 - 16, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForPostTitle, context: nil)
        return rect.height
    }
    
    private func estimateHeightForUserInfo(text: String) -> CGFloat {
        let size = CGSize(width: view.frame.width - 93 - 20 - 16, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForUserInfo, context: nil)
        return rect.height
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postContentController = PostContentController(style: UITableViewStyle.grouped)
        postContentController.post = posts[indexPath.row]
        navigationController?.pushViewController(postContentController, animated: true)
    }
}






