//
//  CourseStackView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseView: UIView {
    
    weak var timetableController: TimetableController?
    
    let courseInfo: CourseInfo
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.5, weight: .bold)]
    let attributesForPlace = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11, weight: .semibold)]
    let attributesForNote = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11, weight: .semibold)]
    
    lazy var courseLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = courseInfo.color
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    init(courseInfo: CourseInfo) {
        self.courseInfo = courseInfo
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = courseInfo.color
        self.layer.cornerRadius = 8
        clipsToBounds = true

        addSubview(courseLabel)
        courseLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 2, bottomConstant: 0, rightConstant: 2, widthConstant: 0, heightConstant: 0)
        setupAttributedText()

        let tapView = UIView()
        tapView.backgroundColor = .clear
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCourseTap)))
        
        addSubview(tapView)
        tapView.fillSuperview()
    }
    
    private func setupAttributedText() {
        let attributedText = NSMutableAttributedString(string: courseInfo.title, attributes: attributesForTitle)

        if courseInfo.place.count > 0 {
            attributedText.appendNewLine()
            attributedText.append(NSMutableAttributedString(string: courseInfo.place, attributes: attributesForPlace))
        }
        
        if courseInfo.note.count > 0 {
            attributedText.appendNewLine()
            attributedText.append(NSMutableAttributedString(string: courseInfo.note, attributes: attributesForNote))
        }
        
        courseLabel.attributedText = attributedText
    }
    
    
    
    @objc func handleCourseTap(_ sender: UIView) {
        let title = getTimeTitle()
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor.black
        alertController.view.isOpaque = true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ (alertAction) in
            
            self.deleteCourseAction()
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (alertAction) in
            let addCourseController = AddCourseController()
            addCourseController.timetableController = self.timetableController
            addCourseController.courseView = self
            let nav = UINavigationController(rootViewController: addCourseController)
            self.timetableController?.present(nav, animated: true, completion: nil)
        }
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        timetableController?.present(alertController, animated: true, completion: nil)
    }
    
    private func getTimeTitle() -> String {
        let startMinutes = courseInfo.times[0]
        let endMinutes = courseInfo.times[1]
        
        let sHours = startMinutes / 60
        let sMinutes = startMinutes % 60
        var startTime = "\(sHours):\(sMinutes)"
        if 0 <= sMinutes && sMinutes <= 9 {
            startTime = "\(sHours):0\(sMinutes)"
        }
        
        let eHours = endMinutes / 60
        let eMinutes = endMinutes % 60
        var endTime = "\(eHours):\(eMinutes)"
        if 0 <= eMinutes && eMinutes <= 9 {
            endTime = "\(eHours):0\(eMinutes)"
        }
        
        let title = "Time: " + startTime + " ~ " + endTime
        
        return title
    }
    
    
    
    public func deleteCourseAction() {
        let timetableDatasource = self.timetableController?.datasource as! TimetableDatasource
        
        guard let timeTableView = self.superview?.superview as? UICollectionView
            else { return }
        
        let indexPath = timeTableView.indexPath(for: self.superview as! UICollectionViewCell)
        
        let i = indexPath!.item
        var dayCourses = timetableDatasource.weekCourses[i]
        
        for j in 0...dayCourses.count - 1 {
            if dayCourses[j].times[0] == self.courseInfo.times[0] && dayCourses[j].times[1] == self.courseInfo.times[1] {
                
                timetableDatasource.weekCourses[i].remove(at: j)
            }
        }
        
        self.timetableController?.collectionView?.reloadData()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






