//
//  UserProfileController.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var userId: String?
    
    var user: User?
    var posts = [Post]()
    var isFinishedPaging = false
    var isPaging = true//fetchUserAndUserPosts
    var queryEndingKey = ""
    
    var queryEndingValue: Date = Date(timeIntervalSince1970: 5000)//for Bookmarks
    var responseArr = [Response]()
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    var choice = TooBarChoice.posts
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        rc.tintColor = themeColor
        return rc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostFooterView.updateProfileBookmarksNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: ResponseController.updateProfileResponseNotificationName, object: nil)
        
        if userId == nil {
            setupLogOutButton()
            setupPostButton()
        }

        fetchUserAndUserPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let school = UserDefaults.standard.getSchool()
        if school == nil {
            self.showEditProfileController()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundView = refreshControl
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.showsVerticalScrollIndicator = false
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserPostResponseCell.self, forCellWithReuseIdentifier: "responseId")
        collectionView?.register(UserPostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: loadingCellId)
    }
    
    private func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    private func setupPostButton() {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "post").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.adjustsImageWhenHighlighted = false
        button.isHidden = true///later for social part, no need for title
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.userProfileController = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if choice == TooBarChoice.response {
            let count = responseArr.count
            return isFinishedPaging ? count : count + 1
        }
        
        let count = posts.count
        return isFinishedPaging ? count : count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        if self.choice == TooBarChoice.response {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "responseId", for: indexPath) as! UserPostResponseCell
            if responseArr.count > indexPath.item {
                cell.response = responseArr[indexPath.item]
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserPostCell
        if posts.count > indexPath.item {
            cell.post = posts[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: view.frame.width, height: 100)
        }
        
        if self.choice == TooBarChoice.response {
            let width = view.frame.width
            let post = responseArr[indexPath.item].post
            let userInfo = post!.user.username + (post!.user.bio ?? "")
            var height: CGFloat = estimateHeightForUserInfo(text: userInfo) + 50 + 14
            
            let postTitleHeight = estimateHeightForPostTitle(text: post!.title)
            height += postTitleHeight
            
            let response = responseArr[indexPath.item]
            let responseUserInfo = response.user.username + (response.user.bio ?? "")
            height += estimateHeightForResponseUserInfo(text: responseUserInfo) + 32
            
            return CGSize(width: width, height: height)
        }
        
        let width = view.frame.width
        let userInfo = posts[indexPath.item].user.username + (posts[indexPath.item].user.bio ?? "")
        var height: CGFloat = estimateHeightForUserInfo(text: userInfo) + 50 + 14
        
        if let imageHeight = posts[indexPath.item].thumbnailImageHeight {
            if imageHeight > 250 { height += 250 }
            else { height += imageHeight }
        }
        
        let postTitleHeight = estimateHeightForPostTitle(text: posts[indexPath.item].title)
        height += postTitleHeight

        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isLoadingIndexPath(indexPath) else { return }
        if !isFinishedPaging && !isPaging {
            if self.choice == TooBarChoice.posts {
                self.paginatePosts()
            } else if self.choice == TooBarChoice.bookmarks {
                self.paginateBookmarks()
            } else {
                self.paginateResponse()
            }
        }
    }

    
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard !isFinishedPaging else { return false }
        
        if choice == TooBarChoice.response {
            return indexPath.row == responseArr.count
        }
        
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
    
    private func estimateHeightForResponseUserInfo(text: String) -> CGFloat {//response user info
        let size = CGSize(width: view.frame.width - 52 - 20 - 16, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForUserInfo, context: nil)
        return rect.height
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if choice == TooBarChoice.response {
            let postContentController = PostContentController(style: UITableViewStyle.grouped)
            let post = responseArr[indexPath.row].post
            postContentController.post = post
            navigationController?.pushViewController(postContentController, animated: true)
            return
        }
        
        let postContentController = PostContentController(style: UITableViewStyle.grouped)
        postContentController.post = posts[indexPath.row]
        navigationController?.pushViewController(postContentController, animated: true)
    }
    
}






