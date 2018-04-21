//
//  PostContentControlle+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import ImageViewer
import LBTAComponents

extension PostContentController: GalleryItemsDataSource, GalleryItemsDelegate, GalleryDisplacedViewsDataSource {
    
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return index < items.count ? items[index].imageView : nil
    }
    
    func removeGalleryItem(at index: Int) {
        print("remove")
    }
    
    func itemCount() -> Int {
        var counter = 0
        
        postMessages.forEach { (postMessage) in
            if postMessage.imageUrl != nil {
                counter = counter + 1
            }
        }
        
        return counter
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
    
    func showGalleryImageViewer(_ sender: UITapGestureRecognizer) {

        guard let cell = sender.view?.superview?.superview as? PostMessageCell else { return }
        guard let imageUrl = cell.postMessage?.imageUrl else { return }
        let displacedViewIndex = getIndexOfImageViews(imageUrl: imageUrl)
        
        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: getGalleryConfiguration())

        let footerView = getPageControlWith(count: items.count)
        if items.count > 1 {
            galleryViewController.footerView = footerView
        }
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        galleryViewController.landedPageAtIndexCompletion = { index in
            print("LANDED AT INDEX: \(index)")
            footerView.currentPage = index
        }
        
        self.presentImageGallery(galleryViewController)
    }
    
    
    
    internal func fetchPostAndResponse() {
        guard let postId = post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userBookmarksRef = Database.database().reference().child("user_bookmarks").child(uid).child(postId)
        let userLikedPostsRef = Database.database().reference().child("user_likedPosts").child(uid).child(postId)
        
        Database.fetchPostWithPID(pid: postId) { (post) in
            let course = self.post?.course
            self.post = post
            self.post?.course = course
            
            userBookmarksRef.observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? Double, value > 5000 {//time
                    self.post?.hasBookmarked = true
                }
                
                userLikedPostsRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let value = snapshot.value as? Double, value == 1 {
                        self.post?.hasLiked = true
                    }
                    
                    Database.fetchPostMessagesWithPID(pid: postId) { (postMessages) in
                        self.postMessages = postMessages
                        self.getDataItemsForGallery()//see down below
                        
                        if self.loadingView.alpha == 1 {
                            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                                self.loadingView.alpha = 0
                            }, completion: nil)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }

        paginateResponse()
    }
    
    internal func paginateResponse() {
        print("\nstart paging")
        guard let postId = post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("post_response").child(postId)
        isPaging = true
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 4
        
        if responseArr.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            var counter = 0
            
            if allObjects.count == 1 || allObjects.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.tableView.reloadData()
            }
            if self.responseArr.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingValue = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let responseId = snapshot.key
                print(responseId)
                
                Database.fetchResponseWithRID(rid: responseId, completion: { (response) in
                    let ref = Database.database().reference().child("user_likedResponse").child(uid).child(responseId)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        var response = response
                        if let value = snapshot.value as? Int, value == 1 {
                            response.hasLiked = true
                        }
                        self.responseArr.append(response)
                        print("inside:   ", response.responseId)
                        
                        Database.fetchResponseMessagesWithRID(rid: responseId) { (responseMessages) in
                            self.responseMessagesDic[responseId] = responseMessages
                            
                            counter = counter + 1
                            if allObjects.count == counter {
                                self.isPaging = false
                                self.tableView.reloadData()
                            }
                        }
                    })
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    
    
    @objc func handleUpdate() {
        if isPaging { return }
        responseArr.removeAll()
        isFinishedPaging = false
        paginateResponse()
    }
    
    @objc func updateResponseCount(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let addFlag = userInfo["add"] as? Bool else { return }
        guard let oldResponseCount = post?.response else { return }
        
        self.post?.response = addFlag ? oldResponseCount + 1 : oldResponseCount - 1
        //wanna reload data? handleUpdate will be called later to do that
    }
    
    @objc func updatePostLikesCount(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let addFlag = userInfo["liked"] as? Bool else { return }
        guard let oldPostLikesCount = post?.likes else { return }
        let topIndexPath = IndexPath(row: 0, section: 0)
        
        self.post?.likes = addFlag ? oldPostLikesCount + 1 : oldPostLikesCount - 1
        tableView.reloadRows(at: [topIndexPath], with: .none)
    }
    
    
    
    private func getGalleryConfiguration() -> GalleryConfiguration {
        
        return [
            GalleryConfigurationItem.deleteButtonMode(ButtonMode.none),
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
    
    private func getDataItemsForGallery() {
        postMessages.forEach { (postMessage) in
            
            if postMessage.imageUrl != nil {
                let imageView = CachedImageView(cornerRadius: 0)
                let galleryItem = GalleryItem.image(fetchImageBlock: { (imageCompletion) in
                    imageView.loadImage(urlString: postMessage.imageUrl!, completion: {
                        imageCompletion(imageView.image)
                    })
                })
                
                items.append(DataItem(imageView: imageView, galleryItem: galleryItem))
            }
        }
    }
    
    private func getIndexOfImageViews(imageUrl: String) -> Int {
        var counter = 0
        var hit = -1
        
        postMessages.forEach { (postMessage) in
            if let url = postMessage.imageUrl {
                if url == imageUrl {
                    hit = counter
                }
                counter = counter + 1
            }
        }
        
        return hit
    }
    
    private func getPageControlWith(count: Int) -> UIPageControl {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let pageControl = UIPageControl(frame: frame)
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = themeColor
        return pageControl
    }
    
}



