//
//  RequestController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class RequestController: HomeController {
    
    var school: String?
    
    override func viewDidLoad() {
        school = UserDefaults.standard.getSchool()
        configureCollectionVeiw()
        configureNavigationBar()
        
        view.addSubview(getStartedButton)
        getStartedButton.setTitle("Add Your Skill", for: .normal)
        getStartedButton.addTarget(self, action: #selector(handleAddSkill), for: .touchUpInside)
        
        getStartedButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 42)
        getStartedButton.anchorCenterXToSuperview()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: SetSkillsController.addSkillNotificationName, object: nil)
        
        fetchUserSkillsPostIds()
    }
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "Can You Help"
        
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "post").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.setTitle("Skill", for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        button.isHidden = true//feels weird to have it

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.theEndLabel.isHidden = false
            cell.theEndLabel.text = "no more questions"
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if posts.count > indexPath.item {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    
    
    private func fetchUserSkillsPostIds() {
        self.getStartedButton.isHidden = true
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let school = school else { return }
        let followingRef = Database.database().reference().child("user_skills").child(uid).child(school)
        let query = followingRef.queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in//outside
            if self.refreshControl.isRefreshing {//prevent jerky scrolling!!!!!
                self.refreshControl.endRefreshing()
            }
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else { return }
            if allObject.count == 0 {
                self.getStartedButton.isHidden = false
                self.isFinishedPaging = true
                self.isPaging = false
                self.collectionView?.reloadData()
            }
            guard let courseIdsDictionary = snapshot.value as? [String: Any] else {return}
            var skillsCounter = 0
            
            courseIdsDictionary.forEach({ (courseId, value) in
                print("courseId:   ", courseId)
                let ref = Database.database().reference().child("school_course_posts").child(school).child(courseId)
                let query = ref.queryOrderedByKey()
                let queryNum: UInt = 20
                
                query.queryLimited(toLast: queryNum).observeSingleEvent(of: .value, with: { (snapshot) in//inside
                    skillsCounter = skillsCounter + 1
                    guard let postIdsDictionary = snapshot.value as? [String: Any] else {
                        if courseIdsDictionary.count == skillsCounter {
                            self.sortPostIds()
                            
                            print("the last skill has no posts")
                            self.paginatePosts()
                        }
                        return
                    }
                    var postIdsCounter = 0
                    
                    postIdsDictionary.forEach({ (postId, value) in
                        print(postId)
                        self.postIds.append(postId)
                        postIdsCounter = postIdsCounter + 1
                        
                        if postIdsDictionary.count == postIdsCounter && courseIdsDictionary.count == skillsCounter {
                            print("last skill postIdsCounter:   ", postIdsCounter)
                            print("skillsCounter:   ", skillsCounter)
                            
                            self.sortPostIds()
                            
                            self.paginatePosts()
                        }
                    })
                })
            })
        }) { (err) in
            print("Failed to fetch following user ids:", err)
        }
    }
    
    @objc internal override func paginatePosts() {
        if postIds.count == 0 {
            self.isFinishedPaging = true
            self.isPaging = false
            self.collectionView?.reloadData()
            print("no postIds")
            return
        }
        print("\nstart paging")
        let queryNum = 4
        isPaging = true
        var endIndex = queryStartingIndex + queryNum
        if endIndex >= postIds.count - 1 {
            endIndex = postIds.count - 1
            isFinishedPaging = true
        }
        let subPostIds = postIds[queryStartingIndex...endIndex]
        queryStartingIndex = endIndex + 1
        var counter = 0
        
        subPostIds.forEach { (postId) in
            Database.fetchPostWithPID(pid: postId, completion: { (post) in
                if post.type == postTypes[0] {
                    self.posts.append(post)
                    print("inside:   ", post.postId)
                    let dummyImageView = CachedImageView()//preload image
                    dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                }
                
                counter = counter + 1
                if subPostIds.count == counter {
                    self.isPaging = false
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    
    
    @objc override func handleRefresh() {
        if isPaging { return }
        postIds.removeAll()
        posts.removeAll()
        queryStartingIndex = 0
        self.isFinishedPaging = false
        fetchUserSkillsPostIds()
    }
    
    @objc func handleAddSkill() {
        let setSkillsController = SetSkillsController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(setSkillsController, animated: true)
    }
    
}





