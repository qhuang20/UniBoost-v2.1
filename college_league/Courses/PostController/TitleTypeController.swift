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
        tv.font = UIFont.boldSystemFont(ofSize: 20)
        return tv
    }()
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return lineView
    }()
    
    var labels = [UILabel]()
    let borderColor = UIColor.lightGray.cgColor
    let selectedBorderColor = UIColor.orange.cgColor
    let textColor = UIColor.lightGray
    
    lazy var typesView: UIStackView = {
        
        for i in 0...3 {
            let label = UILabel()
            label.backgroundColor = UIColor.yellow
            label.layer.cornerRadius = 12
            label.layer.borderColor = borderColor
            label.layer.borderWidth = 2
            label.clipsToBounds = true
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.text = postTypes[i]
            label.textColor = textColor
            if i == 0 {
                label.textColor = UIColor.orange
                label.layer.borderColor = selectedBorderColor
            }
            label.textAlignment = .center
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectedType)))
            label.isUserInteractionEnabled = true
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
        
        titleTextView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 22, leftConstant: 25, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)
        
        separatorLineView.anchor(titleTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0.5)
        
        typesView.anchor(titleTextView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 22, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 200)
        typesView.anchorCenterXToSuperview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        titleTextView.resignFirstResponder()
    }
    
    private func setupNavigationButtons() {
        navigationItem.title = "Add a Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        let button = UIButton(type: .custom)
        button.setTitle("Next", for: .normal)
        button.tintColor = UIColor.white
        button.adjustsImageWhenHighlighted = false//fix the darken
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
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
    
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {///text.count > 0
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
        }
        
        selectedLabel.textColor = UIColor.orange
        selectedLabel.layer.borderColor = selectedBorderColor
        
        let selectedLabelIndex = labels.index(of: selectedLabel)
        selectedType = postTypes[selectedLabelIndex!]
    }
    
}








