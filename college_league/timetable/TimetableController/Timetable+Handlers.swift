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
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
}
