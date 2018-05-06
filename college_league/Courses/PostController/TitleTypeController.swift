//
//  CaptionTypeController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-25.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

let postTypes = ["Question", "Resource", "Book for Sale", "Other"]

class TitleTypeController: UIViewController, UITextViewDelegate {
    
    var selectedType = postTypes[0] 

    var course: Course?

    lazy var titleTextView: UITextView = {
        let tv = UITextView()
        tv.text = " • Provide a 'Title' and a 'Type'"
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.backgroundColor = .white
        tv.textColor = UIColor.lightGray
        tv.returnKeyType = .done
        tv.font = UIFont.boldSystemFont(ofSize: 20)
        return tv
    }()
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return lineView
    }()
    
    var labels = [UILabel]()
    
    let selectedBorderColor = lightThemeColor.cgColor
    let borderColor = themeColor.cgColor
    
    let selectedBackgroundColor = themeColor
    let backgroundColor = UIColor.white
    
    let selectedTextColor = UIColor.white
    let textColor = themeColor
    
    let selectedImageColor = UIColor.white
    let imageColor = lightThemeColor
    
    lazy var typesView: UIStackView = {
        for i in 0...3 {
            let label = UILabel()
            label.backgroundColor = backgroundColor
            label.textColor = textColor
            label.layer.borderColor = borderColor
            label.layer.cornerRadius = 12
            label.layer.borderWidth = 2
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.text = postTypes[i]
            if i == 0 {
                label.textColor = selectedTextColor
                label.layer.borderColor = selectedBorderColor
                label.backgroundColor = selectedBackgroundColor
            }
            label.textAlignment = .center
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedType)))
            label.isUserInteractionEnabled = true
            
            let typeImageView = UIImageView()
            typeImageView.contentMode = .scaleToFill
            typeImageView.image = UIImage(named: postTypes[i])
            typeImageView.image = typeImageView.image?.withRenderingMode(.alwaysTemplate)
            typeImageView.tintColor = imageColor
            if i == 0 {
                typeImageView.tintColor = selectedImageColor
            }
            
            label.addSubview(typeImageView)
            typeImageView.anchor(label.topAnchor, left: label.leftAnchor, bottom: label.bottomAnchor, right: nil, topConstant: 8, leftConstant: 10, bottomConstant: 8, rightConstant: 0, widthConstant: 24, heightConstant: 0)
            
            labels.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: labels)
        sv.distribution = .fillEqually
        sv.axis = UILayoutConstraintAxis.vertical
        sv.spacing = 10
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButtons()
        view.backgroundColor = .white
        moveCursorToHead()
        
        view.addSubview(titleTextView)
        view.addSubview(separatorLineView)
        view.addSubview(typesView)
        
        titleTextView.anchor(view.safeAreaTopAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 22, leftConstant: 25, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)
        
        separatorLineView.anchor(titleTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0.5)
        
        typesView.anchor(titleTextView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 22, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 200)
        typesView.anchorCenterXToSuperview()
        
        
        
        print(view.frame.height)
        if view.frame.height < 570 {//iPhone SE
            hideKeyboardWhenTappedAround()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleTextView.resignFirstResponder()
    }
    
    private func setupNavigationButtons() {
        navigationItem.title = "Add a Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    private func moveCursorToHead() {
        let nextPostion = titleTextView.beginningOfDocument
        titleTextView.selectedTextRange = titleTextView.textRange(from: nextPostion, to: nextPostion)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if titleTextView.textColor == UIColor.lightGray {
            titleTextView.text = ""
            titleTextView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        if titleTextView.text.count == 0 {
            popUpErrorView(text: "Insert a Title")
            return
        }
        
        if titleTextView.text.count > 0 && titleTextView.textColor == UIColor.black {
            let postController = PostController()
            postController.postTitle = titleTextView.text
            postController.postType = selectedType
            postController.course = course
            
            navigationController?.pushViewController(postController, animated: true)
        }
    }
    
    @objc func handleSelectedType(recognizer: UITapGestureRecognizer) {
        let selectedLabel = recognizer.view as! UILabel

        for label in labels{
            label.textColor = textColor
            label.layer.borderColor = borderColor
            label.backgroundColor = backgroundColor
            label.subviews.first?.tintColor = imageColor
        }
        
        selectedLabel.textColor = selectedTextColor
        selectedLabel.layer.borderColor = selectedBorderColor
        selectedLabel.backgroundColor = selectedBackgroundColor
        selectedLabel.subviews.first?.tintColor = selectedImageColor
        
        let selectedLabelIndex = labels.index(of: selectedLabel)
        selectedType = postTypes[selectedLabelIndex!]
    }
    
}








