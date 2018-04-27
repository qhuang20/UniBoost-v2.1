//
//  AddCourseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class AddCourseController: DatasourceController {
    
    var courseInfo = CourseInfo()
    
    var courseView: CourseView? {//from Edit for calling "delete"; copy; rendering
        didSet {//set up courseInfo
            courseInfo = courseView?.courseInfo.copy() as! CourseInfo
            
            let timeTableView = courseView?.superview?.superview as! UICollectionView
            let indexPath = timeTableView.indexPath(for: courseView?.superview as! UICollectionViewCell)
            var boolArr = [Bool]()
            for _ in 0...4 {
                boolArr.append(false)
            }
            boolArr[indexPath!.item] = true
            
            courseInfo.days = boolArr
        }
    }
    
    weak var timetableController: TimetableController?
    
    lazy var dimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDatePicker)))
        return dv
    }()
    
    var leftTimeButton: UIButton?
    var rightTimeButton: UIButton?
    var bottomAnchor: NSLayoutConstraint?
    
    lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.timeZone = NSTimeZone.local
        dp.datePickerMode = .time
        dp.minuteInterval = 5
        dp.backgroundColor = .white
        
        let startHour: Int = 8
        let endHour: Int = 20
        let date = Date()
        let gregorian = Calendar(identifier: Calendar.Identifier.buddhist)
        var components = gregorian.dateComponents(([.day, .month, .year]), from: date)
        
        components.hour = startHour
        components.minute = 0
        components.second = 0
        let startDate = gregorian.date(from: components)
        
        components.hour = endHour
        components.minute = 0
        components.second = 0
        let endDate = gregorian.date(from: components)
    
        dp.minimumDate = startDate
        dp.maximumDate = endDate

        dp.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return dp
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = AddCourseDatasource()
        (datasource as! AddCourseDatasource).oldCourseViewColor = courseInfo.color
        (datasource as! AddCourseDatasource).editCourseBoolArray = courseInfo.days

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        collectionView?.keyboardDismissMode = .onDrag
        configureNavigationItems()

        view?.addSubview(dimView)
        view?.addSubview(datePicker)
       
        dimView.anchor(view?.topAnchor, left: view?.leftAnchor, bottom: view?.bottomAnchor, right: view?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        bottomAnchor = datePicker.anchorWithReturnAnchors(nil, left: view?.leftAnchor, bottom: view?.safeAreaLayoutGuide.bottomAnchor, right: view?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -200, rightConstant: 0, widthConstant: 0, heightConstant: 200)[1]
        
        dimView.isHidden = true
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "Add Course"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveCourseInfo))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCanel))
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
        
        let arr = ["", courseView?.courseInfo.title, courseView?.courseInfo.place, courseView?.courseInfo.note]
        cell.infoTextField.text = arr[indexPath.item]
    
        return cell
    }
    
    private func createTimeButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return button
    }
    
    private func setupTimeButtons(cell: InfoCell) {
        cell.infoTextField.isHidden = true
        
        leftTimeButton = createTimeButton(title: "9:00 AM")
        rightTimeButton = createTimeButton(title: "10:00 AM")
        if courseView != nil {
            let startTime = getTimeTitle(minutes: courseInfo.times[0])
            let endTime = getTimeTitle(minutes: courseInfo.times[1])
            leftTimeButton?.setTitle(startTime, for: .normal)
            rightTimeButton?.setTitle(endTime, for: .normal)
        }
        
        guard let leftTimeButton = leftTimeButton else { return }
        guard let rightTimeButton = rightTimeButton else { return }
        
        let slashLabel = UILabel()
        slashLabel.textColor = .black
        slashLabel.text = "-"
        slashLabel.textAlignment = .center
        slashLabel.font = UIFont.systemFont(ofSize: 26)

        cell.addSubview(leftTimeButton)
        cell.addSubview(slashLabel)
        cell.addSubview(rightTimeButton)

        leftTimeButton.anchor(cell.topAnchor, left: cell.textLabel.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 0)
        
        slashLabel.anchor(cell.topAnchor, left: leftTimeButton.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 25, heightConstant: 0)
        
        rightTimeButton.anchor(cell.topAnchor, left: slashLabel.rightAnchor, bottom: cell.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 0)
    }
    
    private func getTimeTitle(minutes: Int) -> String {

        let hours = minutes / 60
        let minutes = minutes % 60
        var m = ":\(minutes)"
        var h = "\(hours)"
        var amOrPm = " AM"
        
        if 0 <= minutes && minutes <= 9 {
            m = ":0\(minutes)"
        }
        
        if 12 < hours {
            h = "\(hours - 12)"
        }
        
        if 12 <= hours {
            amOrPm = " PM"
        }

        let time = h + m + amOrPm
        
        return time
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



