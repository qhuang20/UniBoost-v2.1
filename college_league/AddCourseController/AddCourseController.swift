//
//  AddCourseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class AddCourseController: DatasourceController {
    
    var courseInfo: CourseInfo?
    
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
    
    var datePickerAnchors: [NSLayoutConstraint]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = AddCourseDatasource()
        collectionView?.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        configureNavigationItems()
        
        courseInfo = CourseInfo()
        
        view.addSubview(datePicker)
        
        datePickerAnchors = datePicker.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "AddCourse"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveCourseInfo))
    }
    
    @objc func saveCourseInfo() {
        
        let keyValues = ["title": infoTextFields[0].text as Any, "place": infoTextFields[1].text as Any, "note": infoTextFields[2].text as Any]
        courseInfo?.setValuesForKeys(keyValues)

    }
    
    var infoTextFields = [UITextField]()
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! InfoCell
        
        cell.infoTextField.tag = indexPath.item
        if (indexPath.item > 0 ) {
            infoTextFields.append(cell.infoTextField)
        }
        
        if indexPath.item == 0 {
            setupTimeButtons(cell: cell)
        }
        
        let labelText = ["Time", "Title", "Place", "Note"]
        cell.textLabel.text = labelText[indexPath.item]
    
        return cell
    }
    
    private func createTimeButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return button
    }
    
    @objc func showDatePicker(button: UIButton) {
        button.setTitleColor(themeColor, for: .normal)
    }
    
    private func setupTimeButtons(cell: InfoCell) {
        cell.infoTextField.isHidden = true
        
        let leftTimeButton = createTimeButton(title: "9:00 AM")
        let rightTimeButton = createTimeButton(title: "10:00 AM")
        let slashLabel = UILabel()
        slashLabel.textColor = .black
        slashLabel.text = "-"
        slashLabel.textAlignment = .center
        slashLabel.font = UIFont.systemFont(ofSize: 26)

        cell.addSubview(leftTimeButton)
        cell.addSubview(slashLabel)
        cell.addSubview(rightTimeButton)

        leftTimeButton.anchor(cell.topAnchor, left: cell.textLabel.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 0)
        
        slashLabel.anchor(cell.topAnchor, left: leftTimeButton.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 0)
        
        rightTimeButton.anchor(cell.topAnchor, left: slashLabel.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 0)
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



