//
//  RequestController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

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





