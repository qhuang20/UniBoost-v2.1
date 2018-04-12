//
//  SetSkillsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-11.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SetSkillsController: CourseController {
    
    override func viewDidLoad() {
        configureCollectionVeiw()
        configureNavigationBar()
        
        view.addSubview(pleaseAddCourseLabel)
        pleaseAddCourseLabel.anchor(view?.safeAreaLayoutGuide.topAnchor, left: view?.leftAnchor, bottom: nil, right: view?.rightAnchor, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
        pleaseAddCourseLabel.isHidden = true
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBarAnchors = searchBar.anchorWithReturnAnchors(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 50, bottomConstant: 2, rightConstant: 60, widthConstant: 0, heightConstant: 0)
        
        school = UserDefaults.standard.getSchool()
        if school == nil {///...set up school First
            isFinishedPaging = true
            self.collectionView?.reloadData()
            return
        }
        
        fetchFollowingCourses()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        previousSearchText = searchBar.text ?? ""
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.alpha = 0
        }) { (_) in
            self.searchBar.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.text = previousSearchText
        searchBar.placeholder = "Find Course"
        searchBar.delegate = self
        
        guard let searchBarAnchors = searchBarAnchors else { return }
        searchBarAnchors[0].constant = 50
        searchBarAnchors[2].constant = -60
        animateNavigationBarLayout()
    }
    
    
    
    override func didSelectCellAt(indexPath: IndexPath) {
        print("show hint")///
    }
    
}










