//
//  HomeController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-13.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class HomeController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "timetable").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleTimetable))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        collectionView?.backgroundColor = UIColor.lightGray
    }
    
    @objc func handleTimetable() {
        let timetableController = TimetableController()
        present(timetableController, animated: true, completion: nil)
    }
    
}


