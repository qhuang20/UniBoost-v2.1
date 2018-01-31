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
        tf.font = UIFont.systemFont(ofSize: 16)
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
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.brown
        //addSubview(textLabel)
    }
    
}

class ColorsFooter: DatasourceCell {
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Show me more"
        label.font = UIFont.systemFont(ofSize: 15)
        //label.textColor = twitterBlue
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = UIColor.brown
        //addSubview(textLabel)
    }
    
}


