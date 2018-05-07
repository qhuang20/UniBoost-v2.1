//
//  UISearchBar+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-07.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    static func getSearchBar() -> UISearchBar {
        let sb = UISearchBar()
        sb.layer.cornerRadius = 10
        sb.clipsToBounds = true
        sb.showsCancelButton = false
        sb.barTintColor = UIColor.white
        sb.returnKeyType = .search
        let textFieldInsideSearchBar = sb.value(forKey: "searchField") as? UITextField
        let button = textFieldInsideSearchBar?.rightView as? UIButton
        button?.tintColor = UIColor.black
        
        if #available(iOS 11.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitlePositionAdjustment(UIOffset(horizontal: 4, vertical: 9), for: UIBarMetrics.default)
            
            let offset = UIOffset(horizontal: 0, vertical: -3)
            sb.searchTextPositionAdjustment = offset
            sb.setPositionAdjustment(offset, for: UISearchBarIcon.search)
            sb.setPositionAdjustment(offset, for: UISearchBarIcon.clear)
            sb.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
            
        } else {
            print("do nothing")
            //ios10
        }

        return sb
    }
    
}

