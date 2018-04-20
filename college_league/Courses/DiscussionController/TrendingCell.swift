//
//  TrendingCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class TrendingCell: DiscussionCell {
    
    var queryEndingLikesValue = 0
    var queryEndingKey = ""
    
    override func paginatePosts() {
        print("\ntrending start paging")
        guard let course = course else { return }
        let searchBar = discussionController?.searchBar
        isPaging = true
        let ref = Database.database().reference().child("school_course_posts").child(course.school).child(course.courseId)
        var query = ref.queryOrderedByValue()
        let queryNum: UInt = 4
        
        if posts.count > 0 {
            query = query.queryEnding(atValue: queryEndingLikesValue, childKey: queryEndingKey)
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
                    })
                }
            }
            if self.posts.count > 0 && allObjects.count > 0 { allObjects.removeFirst() }
            let lastSnapshot = allObjects.last
            guard let likes = lastSnapshot?.value as? Int else { return }
            self.queryEndingLikesValue = likes
            self.queryEndingKey = allObjects.last?.key ?? ""
            
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
                        self.getFilteredPostsWith(searchText: searchBar?.text ?? "")
                        self.tableView.reloadData()
                        
                        if self.loadingView.alpha == 1 {
                            UIView.animate(withDuration: 0.3, animations: {
                                self.loadingView.alpha = 0
                            })
                        }
                    }
                })
            })
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







