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
    
    lazy var dimView: UIView = {
        let dv = UIView()
        dv.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDatePicker)))
        return dv
    }()
    
    var leftTimeButton: UIButton?
    var rightTimeButton: UIButton?
    var bottomAnchor: NSLayoutConstraint?
    var windowView: UIView?
    
    lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.timeZone = NSTimeZone.local
        dp.datePickerMode = .time
        dp.minuteInterval = 5
        dp.backgroundColor = .white
        dp.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return dp
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = AddCourseDatasource()
        collectionView?.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        configureNavigationItems()
        
        courseInfo = CourseInfo()
        courseInfo?.times = [60 * 9, 60 * 10]
        
        windowView = UIApplication.shared.keyWindow
        windowView?.addSubview(dimView)
        windowView?.addSubview(datePicker)
       
        dimView.anchor(windowView?.topAnchor, left: windowView?.leftAnchor, bottom: windowView?.bottomAnchor, right: windowView?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        bottomAnchor = datePicker.anchorWithReturnAnchors(nil, left: windowView?.leftAnchor, bottom: windowView?.safeAreaLayoutGuide.bottomAnchor, right: windowView?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -200, rightConstant: 0, widthConstant: 0, heightConstant: 200)[1]
        
        dimView.isHidden = true
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "AddCourse"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveCourseInfo))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        datePicker.removeFromSuperview()
        dimView.removeFromSuperview()
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
    
    private func setupTimeButtons(cell: InfoCell) {
        cell.infoTextField.isHidden = true
        
        leftTimeButton = createTimeButton(title: "9:00 AM")
        rightTimeButton = createTimeButton(title: "10:00 AM")
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



