//
//  DiscussionCell+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

extension DiscussionCell: UISearchBarDelegate {
    
    @objc internal func paginatePosts() {//to allow override for TrendingCell
        print("\nstart paging")
        guard let course = course else { return }
        let searchBar = discussionController?.searchBar//deprecated
        isPaging = true
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 4
        
        if posts.count > 0 {
            query = query.queryEnding(atValue: queryEndingValue)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            if self.refreshControl.isRefreshing {//prevent jerky scrolling!!!!!
                self.refreshControl.endRefreshing()
            }
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            var counter = 0
            
            if allObjects.count == 1 || allObjects.count == 0 {
                self.isFinishedPaging = true
                self.isPaging = false
                self.tableView.reloadData()
                
                if self.loadingView.alpha == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.loadingView.alpha = 0
                    }, completion: { (_) in
                        if !UserDefaults.standard.isSharingHintShowed() {
                            self.popHintCard()
                        }
                    })
                }
            }
            if self.posts.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            self.queryEndingValue = allObjects.last?.key ?? ""
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                print(postId)
                
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    var post = post
                    post.course = self.course
                    self.posts.append(post)
                    print("inside:   ", post.postId)
                    let dummyImageView = CachedImageView()//preload image
                    dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                    
                    counter = counter + 1
                    if allObjects.count == counter {
                        self.isPaging = false
                        self.getFilteredPostsWith(searchText: searchBar?.text ?? "")//deprecated
                        self.tableView.reloadData()
                        
                        if self.loadingView.alpha == 1 {
                            UIView.animate(withDuration: 0.3, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                                self.loadingView.alpha = 0
                            }, completion: { (_) in
                                if !UserDefaults.standard.isSharingHintShowed() {
                                    self.popHintCard()
                                }
                            })
                        }
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    internal func getFilteredPostsWith(searchText: String) {
        if searchText.isEmpty {
            filteredPosts = posts
        } else {
            filteredPosts = self.posts.filter { (post) -> Bool in
                let postTitle = post.title
                let userName = post.user.username
                let postType = post.type
                let searchContent = postTitle + userName + postType
                return searchContent.lowercased().contains(searchText.lowercased())
            }
        }
        
        if filteredPosts.isEmpty {
            if !isFinishedPaging && !isPaging {
                paginatePosts()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {//deprecated
        if !isFinishedPaging && !isPaging {
            paginatePosts()
        }
        
        if isFinishedPaging {
            self.getFilteredPostsWith(searchText: searchText)
            self.tableView.reloadData()
        }
    }
    
    @objc func handleRefresh() {
        if isPaging { return }
        discussionController?.searchBar?.text  = ""
        let topIndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: false)
        posts.removeAll()//start over
        self.isFinishedPaging = false
        paginatePosts()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {//deprecated
        guard let searchBar = discussionController?.searchBar else { return }
        self.searchBarCancelButtonClicked(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {//deprecated
        searchBar.setShowsCancelButton(true, animated: false)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = nil
        discussionController.searchBarAnchors?[2].constant = -13
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {//deprecated
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.endEditing(true)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = discussionController.postBarButtonItem
        discussionController.searchBarAnchors?[2].constant = -85
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {//deprecated
        searchBar.setShowsCancelButton(false, animated: false)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = discussionController.postBarButtonItem
        discussionController.searchBarAnchors?[2].constant = -85
    }
    
    
    
    private func popHintCard() {
        if discussionController?.navigationController?.visibleViewController?.viewIfLoaded?.window == nil  {
            print("current view is gone")
            return
        }
        UserDefaults.standard.setSharingHintShowed(value: true)
        
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow?.addSubview(self.dimView)
        dimView.fillSuperview()
        dimView.anchorCenterSuperview()

        dimView.addSubview(sharingHintImageView)
        sharingHintImageView.frame = CGRect(x: 0, y: 0, width: 280, height: 280)
        sharingHintImageView.center = CGPoint(x: self.center.x, y: self.center.y)
        sharingHintImageView.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        dimView.addSubview(gotItButton)
        gotItButton.anchorCenterXToSuperview()
        gotItButton.anchor(sharingHintImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 40)
        gotItButton.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
           
            self.sharingHintImageView.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.gotItButton.layer.transform = CATransform3DMakeScale(1, 1, 1)
            
        }, completion: nil)
    }
    
    @objc internal func hideHint() {
        print("Hide Hint")
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            self.sharingHintImageView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            self.gotItButton.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
            
            self.sharingHintImageView.alpha = 0
            self.gotItButton.alpha = 0
            
            self.dimView.alpha = 0
            
        }) { (_) in
            self.dimView.removeFromSuperview()
        }
    }
    
}








