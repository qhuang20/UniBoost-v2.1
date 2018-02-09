//
//  AddCourseController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-31.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension AddCourseController {
    
    @objc func showDatePicker(button: UIButton) {
        for tf in infoTextFields {
            if tf.isFirstResponder {
                tf.resignFirstResponder()
            }
        }
        
        button.setTitleColor(.orange, for: .normal)
        bottomAnchor?.constant = 0
        dimView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.windowView?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func hideDatePicker() {
        leftTimeButton!.setTitleColor(.black, for: .normal)
        rightTimeButton!.setTitleColor(.black, for: .normal)
        
        bottomAnchor?.constant = 200
        dimView.isHidden = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.windowView?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        
        let hours = Calendar.current.component(.hour, from: datePicker.date)
        let minutes = Calendar.current.component(.minute, from: datePicker.date)
        
        let convertedMinutes = 60 * hours + minutes
        
        if leftTimeButton?.titleColor(for: .normal) == UIColor.orange {
            leftTimeButton?.setTitle(selectedDate, for: .normal)
            courseInfo.times[0] = convertedMinutes
        } else {
            rightTimeButton?.setTitle(selectedDate, for: .normal)
            courseInfo.times[1] = convertedMinutes
        }
        
    }
    

    
    @objc func saveCourseInfo() {//only save will pass the data to previous controller
        let timeTableDatasource = timetableController?.datasource as! TimetableDatasource

        let keyValues = ["title": infoTextFields[0].text as Any, "place": infoTextFields[1].text as Any, "note": infoTextFields[2].text as Any]
        courseInfo.setValuesForKeys(keyValues)//courseInfo completed
        
        var returnValue = -1
        
        if courseView != nil {
            returnValue = checkIfCourseIsValid(timetableDatasource: timeTableDatasource, isEditAction: true)
        } else {
            returnValue = checkIfCourseIsValid(timetableDatasource: timeTableDatasource, isEditAction: false)
        }
        
        if returnValue == -1 { return }
        
        if let courseView = courseView {//for edit
            courseView.deleteCourseAction()
        }
        
        for weekday in 0...weekdays.count - 1 {
            if courseInfo.days[weekday] {
                let courseInfoCopy = courseInfo.copy() as! CourseInfo
                timeTableDatasource.weekCourses[weekday].append(courseInfoCopy)//the save
            }
        }
        
        timetableController?.collectionView?.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    private func checkIfCourseIsValid(timetableDatasource: TimetableDatasource, isEditAction: Bool) -> Int {
        if courseInfo.title.count == 0 {
            popUpErrorView(text: "Please set a title")
            return -1
        }
        
        if courseInfo.times[0] >= courseInfo.times[1] {
            popUpErrorView(text: "Please set a right time period")
            return -1
        }

        var hasChoosenDay = false
       
        for weekday in 0...weekdays.count - 1 {
            
            if courseInfo.days[weekday] {
                hasChoosenDay = true
                
                for exsitingCourseInfo in timetableDatasource.weekCourses[weekday] {
                    let exsitingStartTime = exsitingCourseInfo.times[0]
                    let exsitingEndTime = exsitingCourseInfo.times[1]

                    let isValidTime = courseInfo.times[1] <= exsitingStartTime || courseInfo.times[0] >= exsitingEndTime
                    
                    if isEditAction {
                        let timeTableView = courseView?.superview?.superview as! UICollectionView
                        let indexPath = timeTableView.indexPath(for: courseView?.superview as! UICollectionViewCell)
                        
                        let isOldCourseViewTime = exsitingStartTime == courseView?.courseInfo.times[0] && exsitingEndTime == courseView?.courseInfo.times[1]
                        
                        if indexPath?.item == weekday && isOldCourseViewTime { continue }
                    }
                    
                    if !isValidTime {
                        popUpErrorView(text: "Overlap with existing time")
                        return -1
                    }
                }
            }
        }
        
        if !hasChoosenDay {
            popUpErrorView(text: "Please choose a day")
            return -1
        }
        
        return 1
    }
    
    private func popUpErrorView(text: String) {
        let errorView = createErrorView(text: text, color: UIColor.orange, fontSize: 16)
        view.addSubview(errorView)
        errorView.anchorCenterSuperview()
        
        UIView.animate(withDuration: 1, delay: 1.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            errorView.alpha = 0
            
        }, completion: { (didComplete) in
            errorView.removeFromSuperview()
        })
    }
    
    private func createErrorView(text: String, color: UIColor, fontSize: CGFloat) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.backgroundColor = color
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textColor = .white
        
        return label
    }
    
}

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 5.0
    var bottomInset: CGFloat = 5.0
    var leftInset: CGFloat = 8.0
    var rightInset: CGFloat = 8.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
    
}



