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
        print("\(hours)  \(minutes)")
        let convertedMinutes = 60 * hours + minutes
        
        if leftTimeButton?.titleColor(for: .normal) == UIColor.orange {
            leftTimeButton?.setTitle(selectedDate, for: .normal)
            courseInfo?.times?[0] = convertedMinutes
        } else {
            rightTimeButton?.setTitle(selectedDate, for: .normal)
            courseInfo?.times?[1] = convertedMinutes
        }
        
    }
    

    
    @objc func saveCourseInfo() {//only save will pass the data to previous controller
        
        let keyValues = ["title": infoTextFields[0].text as Any, "place": infoTextFields[1].text as Any, "note": infoTextFields[2].text as Any]
        courseInfo?.setValuesForKeys(keyValues)
        
//        print(courseInfo?.days)
//        print(courseInfo?.times)
//        print(courseInfo?.title)
//        print(courseInfo?.place)
//        print(courseInfo?.note)
//        print(courseInfo?.color)
        
        
    }
    
}



