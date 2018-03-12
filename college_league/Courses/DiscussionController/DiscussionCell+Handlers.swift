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
    
    internal func fetchPosts() {
        guard let course = course else { return }
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach({ (key, value) in
                Database.fetchPostWithPID(pid: key, completion: { (post) in
                    self.posts.append(post)
                    
                    if self.posts.count == dictionaries.count {
                        self.filteredPosts = self.posts
                        
                        self.filteredPosts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                        })
                        
                        self.tableView.reloadData()
                    }
                })
            })
        }) { (err) in
            print("Failed to fetch course posts:", err)
        }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if filterType == FilterType.all {
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
        } else {
            if searchText.isEmpty {
                filteredPosts = filteredTypePosts
            } else {
                filteredPosts = self.filteredTypePosts.filter { (post) -> Bool in
                    let postTitle = post.title
                    let userName = post.user.username
                    let postType = post.type
                    let searchContent = postTitle + userName + postType
                    return searchContent.lowercased().contains(searchText.lowercased())
                }
            }
        }
        
        reload(tableView: tableView)
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
    
    
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        dimView.alpha = 1
        typesViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.windowView?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func hideDimView() {
        dimView.alpha = 0
        typesViewBottomAnchor?.constant = 175
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.windowView?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func handleFilterType(selectedButton: UIButton) {
        guard let searchBar = discussionController?.searchBar else { return }
        let searchText = selectedButton.titleLabel?.text
        filterType = DiscussionCell.FilterType(rawValue: searchText!)!
        
        for button in typesView.subviews as! [UIButton] {
            if button == selectedButton {
                button.isSelected = true
                button.tintColor = themeColor
                continue
            }
            button.isSelected = false
            button.tintColor = UIColor.lightGray
        }
        
        if searchText == FilterType.all.rawValue {
            self.searchBar(searchBar, textDidChange: "")
            
        } else {
            filteredTypePosts = self.posts.filter { (post) -> Bool in
                let searchContent = post.type
                return searchContent.lowercased().contains(searchText!.lowercased())
            }
            self.searchBar(searchBar, textDidChange: searchText!)
        }
        
        hideDimView()
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBar = discussionController?.searchBar else { return }
        self.searchBarCancelButtonClicked(searchBar)
    }
    
}




