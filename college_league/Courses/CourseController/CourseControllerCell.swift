//
//  CourseControllerCell.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class CourseControllerCell: UICollectionViewCell {
    
    var course: Course? {
        didSet {
            setupAttributedTitle()
            setupAddEmptyButton()
        }
    }
    
    weak var courseController: CourseController?
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 22)]
    let attributesForDescription = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12.5), NSAttributedStringKey.foregroundColor: UIColor.lightGray]

    private func setupAttributedTitle() {
        guard let course = course else { return }
        
        let attributedText = NSMutableAttributedString(string: course.name, attributes: attributesForTitle)
        attributedText.appendNewLine()
        let attributedCourseNumber =  NSAttributedString(string: course.number, attributes: attributesForTitle)
        attributedText.append(attributedCourseNumber)
        attributedText.appendNewLine()
        
        let attributedCourseDescription = NSAttributedString(string: "• " + course.description, attributes: attributesForDescription)
        attributedText.append(attributedCourseDescription)
        
        courseInfoLabel.attributedText = attributedText
    }
   
    lazy var courseInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 4
        button.layer.borderColor = themeColor.cgColor
        button.layer.borderWidth = 1.5
        button.addTarget(self, action: #selector(handleTapButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        backgroundColor = UIColor.white
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapCell)))
        setupEmptyStyle()
        
        addSubview(courseInfoLabel)
        addSubview(addButton)
        
        courseInfoLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 6, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        addButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 28, heightConstant: 28)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleTapButton(button: UIButton) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        
        if addButton.titleLabel?.text == "✓" {
            ref.child(courseId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unSelect course:", err)
                    return
                }
                
                print("Successfully unSelect course:", courseId)
                self.setupEmptyStyle()
            })
        } else {
            
            let values = [courseId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to add course:", err)
                    return
                }
                
                print("Successfully add course: ", courseId)
                self.setupAddStyle()
            }
        }
    }
    
    @objc func handleTapCell() {
        guard let indexPath = courseController?.collectionView?.indexPath(for: self) else { return }
        courseController?.didSelectCellAt(indexPath: indexPath)
    }
    
    private func setupAddStyle() {
        addButton.setTitle("✓", for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.backgroundColor = themeColor
    }
    
    private func setupEmptyStyle() {
        addButton.setTitle(" ", for: .normal)
        addButton.backgroundColor = UIColor.white
    }
    
    private func setupAddEmptyButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school).child(courseId)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let isAdded = snapshot.value as? Int, isAdded == 1 {
                self.setupAddStyle()
            } else {
                self.setupEmptyStyle()
            }
        }, withCancel: { (err) in
            print("Failed to check if added:", err)
        })
    }
    
}






