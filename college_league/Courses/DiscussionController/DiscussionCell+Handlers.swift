//
//  DiscussionCell+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-03.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension DiscussionCell: UISearchBarDelegate {
    
    internal func paginatePosts() {
        print("start paging")
        guard let course = course else { return }
        guard let searchBar = discussionController?.searchBar else { return }
        isPaging = true
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId)
        var query = ref.queryOrderedByKey()
        let queryNum: UInt = 4
        
        if posts.count > 0 {
            let value = posts.last?.postId
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in
            self.activityIndicatorView.stopAnimating()
            self.refreshControl.endRefreshing()
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            
            if allObjects.count == 1 { self.isFinishedPaging = true }
            if self.posts.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            if allObjects.count == 0 { self.isPaging = false }
            
            allObjects.forEach({ (snapshot) in
                let postId = snapshot.key
                Database.fetchPostWithPID(pid: postId, completion: { (post) in
                    self.posts.append(post)
                    if allObjects.last == snapshot {
                        self.isPaging = false
                        self.getFilteredPostsWith(searchText: searchBar.text ?? "")
                        self.tableView.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    private func getFilteredPostsWith(searchText: String) {
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !isFinishedPaging && !isPaging {
            paginatePosts()
        }
        
        if isFinishedPaging {
            self.getFilteredPostsWith(searchText: searchText)
            self.tableView.reloadData()
        }
    }
    
    @objc func handleRefresh() {
        guard let searchBar = discussionController?.searchBar else { return }
        if searchBar.text != "" {
            refreshControl.endRefreshing()
            return
        }
        posts.removeAll()//start over
        self.isFinishedPaging = false
        if !isPaging { paginatePosts() }
    }
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBar = discussionController?.searchBar else { return }
        self.searchBarCancelButtonClicked(searchBar)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: false)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = nil
        discussionController.searchBarAnchors?[2].constant = -13
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.endEditing(true)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = discussionController.postBarButtonItem
        discussionController.searchBarAnchors?[2].constant = -85
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        
        guard let discussionController = discussionController else { return }
        discussionController.navigationItem.rightBarButtonItem = discussionController.postBarButtonItem
        discussionController.searchBarAnchors?[2].constant = -85
    }
    
}








