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
    
    let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(r: 250, g: 149, b: 122, a: 0.9)
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()
    
    let addSkillImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "addSkillHintCard"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Add your skill to receive \nquestions.\nShare your knowledge\nwith others."
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var sureButton: UIButton = {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.backgroundColor = UIColor(r: 243, g: 232, b: 180, a: 1)
        button.setTitleColor(themeColor, for: .normal)
        button.setTitle("Sure", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.addTarget(self, action: #selector(handleAddSkill), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        school = UserDefaults.standard.getSchool()
        configureCollectionVeiw()
        configureNavigationBar()
        
        view.addSubview(containerView)
        containerView.addSubview(addSkillImageView)
        containerView.addSubview(hintLabel)
        containerView.addSubview(sureButton)
        
        containerView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 50, leftConstant: 50, bottomConstant: 50, rightConstant: 50, widthConstant: 0, heightConstant: 0)
        
        addSkillImageView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        let constraint = NSLayoutConstraint(item: addSkillImageView, attribute: .height, relatedBy: .equal, toItem: addSkillImageView, attribute: .width, multiplier: 1, constant: 0)
        constraint.isActive = true
        addSkillImageView.addConstraint(constraint)//add 1 to 1 raito.
        
        hintLabel.anchor(addSkillImageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 8, leftConstant: 4, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 0)
        hintLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        sureButton.anchor(hintLabel.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
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
        let image = #imageLiteral(resourceName: "add").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.setTitle("Skill", for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        button.addTarget(self, action: #selector(handleAddSkill), for: .touchUpInside)
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
        self.containerView.isHidden = true
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
                self.containerView.isHidden = false
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





