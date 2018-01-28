//
//  AddCourseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class AddCourseController: DatasourceController {
    
    lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.timeZone = NSTimeZone.local
        dp.datePickerMode = .time
        dp.minuteInterval = 5
        dp.backgroundColor = .white
        dp.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return dp
    }()
    
    @objc func datePickerValueChanged(_ datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let selectedDate = dateFormatter.string(from: datePicker.date)
        print("Selected value \(selectedDate)")
        
        let hours = Calendar.current.component(.hour, from: datePicker.date)
        let minutes = Calendar.current.component(.minute, from: datePicker.date)
        print("\(hours)  \(minutes)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = AddCourseDatasource()
        collectionView?.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        
        view.addSubview(datePicker)
        
        datePicker.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
    }
    
    var infoTextFields = [UITextField]()
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! InfoCell
        
        cell.infoTextField.tag = indexPath.item
        infoTextFields.append(cell.infoTextField)
        
        if indexPath.item == 0 {
            cell.infoTextField.isHidden = true
        }
        
        let labelText = ["Time", "Title", "Place", "Note"]
        cell.textLabel.text = labelText[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
  
}



