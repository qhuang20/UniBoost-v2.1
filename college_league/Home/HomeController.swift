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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "timetable").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleTimetable))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        fetchFollowingUserPostIds()
    }
    
    private func configureCollectionVeiw() {
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
        return isFinishedPaging ? count : count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
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
        var height: CGFloat = 50 + 28//userInfo
        let width = view.frame.width
        
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: width, height: 100)
        }
        
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
    
    private func estimateHeightForUserInfo(text: String) -> CGFloat {
        let size = CGSize(width: view.frame.width - 93, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let rect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributesForUserInfo, context: nil)
        return rect.height
    }
    
}


