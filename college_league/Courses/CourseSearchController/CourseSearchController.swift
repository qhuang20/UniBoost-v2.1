//
//  CourseSearchController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-26.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseSearchController: CourseController {
    
    override func viewDidLoad() {
        configureCollectionVeiw()
        searchBar.showsCancelButton = true
        school = UserDefaults.standard.getSchool()
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        _ = searchBar.anchorWithReturnAnchors(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 2, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        searchBar.becomeFirstResponder()
    }
    
    
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool { return true }
    override func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    override func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
}

















