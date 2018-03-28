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
    var isPaging = true
    var queryEndingValue = ""
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        rc.tintColor = themeColor
        return rc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        collectionView?.backgroundView = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: PostController.updateFeedNotificationName, object: nil)
        
        if userId == nil {
            setupLogOutButton()
            setupPostButton()
        }

        fetchUserAndUserPosts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = UIColor.white
        collectionView?.showsVerticalScrollIndicator = false
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
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
        let count = posts.count
        return isFinishedPaging ? count : count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserPostCell
        
        if posts.count > indexPath.item {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 50 + 28//userInfo
        let width = view.frame.width
        
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: width, height: 100)
        }
        
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
            paginatePosts()
        }
    }

    
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard !isFinishedPaging else { return false }
        return indexPath.row == posts.count
    }
    
    private func estimateHeightForPostTitle(text: String) -> CGFloat {
        let attributesForPostTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22)]
        let size = CGSize(width: view.frame.width - 20, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForPostTitle, context: nil)
        return rect.height
    }
    
    private func estimateHeightForUserInfo(text: String) -> CGFloat {///
        UIFont.boldSystemFont(ofSize: 22)
        let size = CGSize(width: view.frame.width - 93, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForUserInfo, context: nil)
        return rect.height
    }
    
}


