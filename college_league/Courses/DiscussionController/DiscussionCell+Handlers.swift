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
    
    internal func fetchPostInfos() {
        guard let course = course else { return }
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }

            dictionaries.forEach({ (key, value) in
                Database.fetchPostInfoWithPID(pid: key, completion: { (postInfo) in
                    self.postInfos.append(postInfo)
                    
                    if self.postInfos.count == dictionaries.count {
                        self.filteredPostInfos = self.postInfos
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
                filteredPostInfos = postInfos
            } else {
                filteredPostInfos = self.postInfos.filter { (postInfo) -> Bool in
                    let postInfoTitle = postInfo.title
                    let userName = postInfo.user.username
                    let postType = postInfo.type
                    let searchContent = postInfoTitle + userName + postType
                    return searchContent.lowercased().contains(searchText.lowercased())
                }
            }
        } else {
            if searchText.isEmpty {
                filteredPostInfos = filteredTypePostInfos
            } else {
                filteredPostInfos = self.filteredTypePostInfos.filter { (postInfo) -> Bool in
                    let postInfoTitle = postInfo.title
                    let userName = postInfo.user.username
                    let postType = postInfo.type
                    let searchContent = postInfoTitle + userName + postType
                    return searchContent.lowercased().contains(searchText.lowercased())
                }
            }
        }
        
        self.tableView.reloadData()
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
            
            filteredTypePostInfos = self.postInfos.filter { (postInfo) -> Bool in
                let postInfoTitle = postInfo.title
                let userName = postInfo.user.username
                let postType = postInfo.type
                let searchContent = postInfoTitle + userName + postType
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




