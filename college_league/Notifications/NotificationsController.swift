//
//  NotificationsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-16.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class NotificationsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notifications"
        view.backgroundColor = brightGray
        
        let comingSoonLabel = UILabel()
        comingSoonLabel.text = "Coming Soon"
        comingSoonLabel.textColor = UIColor.lightGray
        view.addSubview(comingSoonLabel)
        
        comingSoonLabel.anchorCenterSuperview()
    }
    
}

