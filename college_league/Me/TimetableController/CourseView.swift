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
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(courseInfo: CourseInfo) {
        self.courseInfo = courseInfo
        super.init(frame: .zero)
        setupView()
    }
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fill
        sv.alignment = .fill
        sv.axis = .vertical
        return sv
    }()
    
    private func createLabel(text: String, color: UIColor, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = color
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    
        label.textAlignment = .center
        label.textColor = .white
        
        label.numberOfLines = 0
        return label
    }

    private func setupView() {
        self.backgroundColor = courseInfo.color
        self.layer.cornerRadius = 8
        clipsToBounds = true

        addSubview(stackView)
        stackView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 2, leftConstant: 1, bottomConstant: 0, rightConstant: 1, widthConstant: 0, heightConstant: 0)//text has intrinsic size
        
        if courseInfo.title.count > 0 {
            let titleLabel = createLabel(text: courseInfo.title, color: courseInfo.color, fontSize: 12.5)
            titleLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .bold)
            stackView.addArrangedSubview(titleLabel)
        }
        
        if courseInfo.place.count > 0 {
            let placeLabel = createLabel(text: courseInfo.place, color: courseInfo.color, fontSize: 11)
            stackView.addArrangedSubview(placeLabel)
        }

        if courseInfo.note.count > 0 {
            let noteLabel = createLabel(text: courseInfo.note, color: courseInfo.color, fontSize: 11)
            stackView.addArrangedSubview(noteLabel)
        }
        
        let tapView = UIView()
        tapView.backgroundColor = .clear
        tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCourseTap)))
        
        addSubview(tapView)
        tapView.fillSuperview()
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
        self.timetableController?.navigationController?.pushViewController(addCourseController, animated: true)
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
    
}






