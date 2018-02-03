//
//  CourseInfoCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

class InfoCell: DatasourceCell, UITextFieldDelegate {
        
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(r: 130, g: 130, b: 130)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.placeholder = ""///
        tf.returnKeyType = .next
        tf.delegate = self
        return tf
    }()
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        separatorLineView.backgroundColor = themeColor
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
        
        let addCourseController = controller as! AddCourseController
        let infoTextFields = addCourseController.infoTextFields
        
        for tf in infoTextFields {
            if let nextTextField = tf.viewWithTag(infoTextField.tag + 1) {
                nextTextField.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        separatorLineView.backgroundColor = brightGray
    }
    
    override func setupViews() {
        separatorLineView.isHidden = false
        separatorLineView.backgroundColor = brightGray
       
        addSubview(textLabel)
        addSubview(separatorLineView)
        addSubview(infoTextField)
        
        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0.8)
        
        textLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 0)
        
        infoTextField.anchor(topAnchor, left: textLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 26, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
}

class DaysHeader: DatasourceCell {
    
    lazy var daysStackView: UIStackView = {
        var views = [UIView]()
        for i in 0...4 {
            let label = UILabel()
            label.backgroundColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.text = weekdays[i]
            label.tag = i
            if i == 0 {
                label.textColor = UIColor.orange
            }
            label.textAlignment = .center
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedDay)))
            label.isUserInteractionEnabled = true
            views.append(label)
        }
        let sv = UIStackView(arrangedSubviews: views)
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    @objc func handleSelectedDay(recognizer: UITapGestureRecognizer) {
        let selectedLabel = recognizer.view as! UILabel
        let isAlreadySelected = selectedLabel.textColor == UIColor.orange
        
        let addCourseController = controller as! AddCourseController
        let tag = selectedLabel.tag
       
        addCourseController.courseInfo?.days[tag] = !isAlreadySelected
        selectedLabel.textColor = isAlreadySelected ? UIColor.black : UIColor.orange
    }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = UIColor.white
        
        addSubview(daysStackView)
        
        daysStackView.anchorCenterSuperview()
        daysStackView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.frame.width - 100, heightConstant: self.frame.height)
    }
    
}

class ColorsFooter: DatasourceCell {
    let colors = [UIColor(r: 255, g: 144, b: 0),
                  UIColor(r: 170, g: 0, b: 0),
                  UIColor(r: 156, g: 80, b: 0),
                  UIColor(r: 0, g: 151, b: 0),
                  UIColor(r: 0, g: 144, b: 255),
                  UIColor(r: 166, g: 0, b: 255),
                  UIColor(r: 94, g: 0, b: 152),
                  UIColor(r: 129, g: 112, b: 255),
                  UIColor(r: 0, g: 79, b: 152)]

    var labels = [UILabel]()

    lazy var colorsStackView: UIStackView = {
        for i in 0..<colors.count {
            let label = UILabel()
            label.backgroundColor = colors[i]
            if i == 0 {
                label.text = "✓"
            } else {
                label.text = " "
            }
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textAlignment = .center
            label.layer.cornerRadius = 12
            label.clipsToBounds = true
            label.textColor = UIColor.white
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedColor)))
            label.isUserInteractionEnabled = true
            labels.append(label)
        }
        let sv = UIStackView(arrangedSubviews: labels)
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()
    
    @objc func handleSelectedColor(recognizer: UITapGestureRecognizer) {
        let selectedLabel = recognizer.view as! UILabel
        let addCourseController = controller as! AddCourseController
        
        for label in labels {
            label.text = " "
        }
        
        selectedLabel.text = "✓"
        addCourseController.courseInfo?.color = selectedLabel.backgroundColor!
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(colorsStackView)
        
        colorsStackView.anchorCenterSuperview()
        colorsStackView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: self.frame.width - 50, heightConstant: self.frame.height)
    }
    
}


