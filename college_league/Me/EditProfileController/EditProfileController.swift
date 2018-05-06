//
//  EditProfileController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-28.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

class EditProfileController: UIViewController {
   
    var user: User?
    
    let words = ["My School", "My Skills", "Edit Photo", "Edit Name", "Bio:"]
    let wordsLimitForBio = 65
    
    lazy var leftStackView: UIStackView = {
        var labels = [UILabel]()
 
        for i in 0...4 {
            let label = UILabel()
            let separatorLineView: UIView = {
                let lineView = UIView()
                lineView.backgroundColor = UIColor(white: 0, alpha: 0.2)
                return lineView
            }()
            if i == 0 {
                separatorLineView.isHidden = true
            }
            label.addSubview(separatorLineView)
            separatorLineView.anchor(label.topAnchor, left: label.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 600, heightConstant: 0.5)
            
            label.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
            label.text = words[i]
            label.textAlignment = .left
            label.backgroundColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 16)
            labels.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: labels)
        sv.distribution = .fillEqually
        sv.axis = UILayoutConstraintAxis.vertical
        sv.spacing = 0
        return sv
    }()
    
    lazy var schoolLabel: UILabel = {
        let label = UILabel()
        label.text = "Langara"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var schoolLabelHolder: UIView = {
        let v = UIView()
        let rightArrowButton = UIButton(type: .system)
        rightArrowButton.setImage(#imageLiteral(resourceName: "rightArrow"), for: .normal)
        rightArrowButton.tintColor = UIColor.gray
        rightArrowButton.addTarget(self, action: #selector(handleSetSchool), for: .touchUpInside)
        
        v.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        v.backgroundColor = UIColor.white
        v.addSubview(rightArrowButton)
        v.addSubview(schoolLabel)
        
        rightArrowButton.anchor(nil, left: nil, bottom: nil, right: v.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        rightArrowButton.anchorCenterYToSuperview()
        
        schoolLabel.anchor(nil, left: v.leftAnchor, bottom: nil, right: rightArrowButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        schoolLabel.anchorCenterYToSuperview()
        
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSetSchool)))
        return v
    }()
    
    lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "rightArrow"), for: .normal)
        button.tintColor = UIColor.gray
        return button
    }()
    
    lazy var rightArrowButtonHolder: UIView = {
        let v = UIView()
        v.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        v.backgroundColor = UIColor.white
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSetSkills)))
        v.addSubview(rightArrowButton)
        
        rightArrowButton.anchor(nil, left: nil, bottom: nil, right: v.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        rightArrowButton.anchorCenterYToSuperview()
        rightArrowButton.addTarget(self, action: #selector(handleSetSkills), for: .touchUpInside)
        return v
    }()
    
    lazy var profileImageView: CachedImageView = {
        let iv = CachedImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = brightGray
        return iv
    }()
    
    lazy var imageViewHolder: UIView = {
        let v = UIView()
        v.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        v.backgroundColor = UIColor.white
        v.addSubview(profileImageView)
        profileImageView.anchor(nil, left: v.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        profileImageView.anchorCenterYToSuperview()
        
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        return v
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        tf.backgroundColor = UIColor.white
        tf.autocorrectionType = .no
        return tf
    }()
    
    lazy var rightStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [schoolLabelHolder, rightArrowButtonHolder, imageViewHolder, nameTextField])
        sv.distribution = .fill
        sv.alignment = .fill
        sv.axis = UILayoutConstraintAxis.vertical
        sv.spacing = 0
        return sv
    }()
    
    lazy var bioTextView: CustomInputTextView = {
        let textView = CustomInputTextView()
        textView.placeholderLabel.text = "Say somthing about myself ..."
        textView.placeholderLabel.font = UIFont.systemFont(ofSize: 15)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(white: 0, alpha: 0.05)
        textView.delegate = self
        textView.returnKeyType = .done
        textView.autocorrectionType = .no
        return textView
    }()
    
    lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureNavigationItems()
        setupInputAccessoryViewForBio()
        
        view.addSubview(rightStackView)
        view.addSubview(leftStackView)
        view.addSubview(bioTextView)
        
        leftStackView.anchor(view.safeAreaTopAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 25, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 0)
        
        rightStackView.anchor(view.safeAreaTopAnchor, left: leftStackView.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 50, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        bioTextView.anchor(leftStackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: -8, leftConstant: 22, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)
        
        setupUserInfo()
        
        
        
        print(view.frame.height)
        if view.frame.height < 570 {//iPhone SE
            observeKeyboardShowHideNotifications()
            hideKeyboardWhenTappedAround()
        }
    }
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleCanel))
    }
    
    private func setupInputAccessoryViewForBio() {
        let inputContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        inputContainerView.backgroundColor = UIColor.clear
        
        inputContainerView.addSubview(textCountLabel)
        textCountLabel.anchor(nil, left: nil, bottom: inputContainerView.bottomAnchor, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 44, heightConstant: 44)
        
        bioTextView.inputAccessoryView = inputContainerView
    }
    
    private func setupUserInfo() {
        guard let user = user else { return }
        let school = UserDefaults.standard.getSchool()
        schoolLabel.text = school
        nameTextField.text = user.username
        bioTextView.text = user.bio
        if bioTextView.text.count > 0 {
            bioTextView.placeholderLabel.isHidden = true
        }
        textCountLabel.text = "\(wordsLimitForBio - bioTextView.text.count)"
        profileImageView.loadImage(urlString: user.profileImageUrl)
        
        if school == nil {
            handleSetSchool()
        }
    }
    
}




