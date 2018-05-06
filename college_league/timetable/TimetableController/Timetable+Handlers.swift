//
//  Timetable+handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension TimetableController: UIViewControllerTransitioningDelegate {
    
    @objc func addNewCourse() {
        let addCourseController = AddCourseController()
        let nav = UINavigationController(rootViewController: addCourseController)
        addCourseController.timetableController = self
        present(nav, animated: true, completion: nil)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}



//https://gist.github.com/eoghain/7e9afdd43d1357fb8824126e0cbd491d
class CustomInteractiveAnimationNavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
   
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
    }
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
}











