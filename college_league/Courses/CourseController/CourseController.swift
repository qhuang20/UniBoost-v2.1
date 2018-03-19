//
//  CourseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var school: String? = "Langara College"

    var courses = [Course]()
    var followingCourses = [Course]()
    var filteredCourses = [Course]()

    let cellId = "cellId"
    var searchBarAnchors: [NSLayoutConstraint]?
    var viewOptionButton: UIButton?
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.layer.cornerRadius = 10
        sb.clipsToBounds = true
        sb.showsCancelButton = false
        sb.barTintColor = UIColor.white
        sb.returnKeyType = .done
        let textFieldInsideSearchBar = sb.value(forKey: "searchField") as? UITextField
        let button = textFieldInsideSearchBar?.rightView as? UIButton
        button?.tintColor = UIColor.black
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitlePositionAdjustment(UIOffset(horizontal: 4, vertical: 9), for: UIBarMetrics.default)
        
        let offset = UIOffset(horizontal: 0, vertical: -3)
        sb.searchTextPositionAdjustment = offset
        sb.setPositionAdjustment(offset, for: UISearchBarIcon.search)
        sb.setPositionAdjustment(offset, for: UISearchBarIcon.clear)
        sb.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 12)
        return sb
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.text = ""
        searchBar.placeholder = "Find Course"
        searchBar.delegate = self
        
        guard let searchBarAnchors = searchBarAnchors else { return }
        searchBarAnchors[0].constant = 20
        searchBarAnchors[2].constant = -60
        animateNavigationBarLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        configureNavigationBar()
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        
        searchBarAnchors = searchBar.anchorWithReturnAnchors(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 2, rightConstant: 60, widthConstant: 0, heightConstant: 0)
        
        if school == nil {///...set up school in Me...
            return
        }
        
        fetchCourses()
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        
        collectionView?.register(CourseControllerCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    private func configureNavigationBar() {
        let button = UIButton(type: .custom)
        viewOptionButton = button
        let image = #imageLiteral(resourceName: "eye").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        let selectedImage = #imageLiteral(resourceName: "eye_selected").withRenderingMode(.alwaysTemplate)
        button.setImage(selectedImage, for: .selected)
        button.tintColor = UIColor.white
        button.adjustsImageWhenHighlighted = false
        button.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 34, heightConstant: 30)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 2)
        button.addTarget(self, action: #selector(handleViewOption), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    
    
    func didSelectCellAt(indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)

        let course = filteredCourses[indexPath.item]
        let discussionController = DiscussionController(collectionViewLayout: UICollectionViewFlowLayout())
        discussionController.course = course
        discussionController.searchBar = searchBar
        discussionController.searchBarAnchors = searchBarAnchors

        navigationController?.pushViewController(discussionController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCourses.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CourseControllerCell
        cell.course = filteredCourses[indexPath.item]
        cell.courseController = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        let width = (view.frame.width - 12 - 16) / 3
        return CGSize(width: width, height: width)
    }
    
    private func animateNavigationBarLayout() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.navigationController?.navigationBar.layoutIfNeeded()
        }, completion: nil)
    }
    
}







