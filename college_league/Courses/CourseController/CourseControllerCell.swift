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
            guard let course = course else { return }
            setupAttributedTitle()
            course.hasFollowed == true ? setupAddedStyle() : setupEmptyStyle()
            
            self.layer.borderWidth = 2
            if course.postsCount > 0 {
                self.layer.borderColor = UIColor(r: 255, g: 200, b: 0).cgColor
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    weak var courseController: CourseController?
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.5)]
    let attributesForCourseInfo = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 11.5), NSAttributedStringKey.foregroundColor: UIColor.lightGray]

    private func setupAttributedTitle() {
        guard let course = course else { return }
        
        let attributedText = NSMutableAttributedString(string: course.name, attributes: attributesForTitle)
        attributedText.appendNewLine()
        let attributedCourseNumber =  NSAttributedString(string: course.number, attributes: attributesForTitle)
        attributedText.append(attributedCourseNumber)
        attributedText.appendNewLine()
        
        let attributedCourseInfo = NSAttributedString(string: "• " + course.description, attributes: attributesForCourseInfo)
        attributedText.append(attributedCourseInfo)
        
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
        button.setTitle(" ", for: .normal)
        button.setTitle("✓", for: .selected)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .selected)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(handleTapButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        backgroundColor = UIColor.white
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapCell)))
        
        addSubview(courseInfoLabel)
        addSubview(addButton)
        
        courseInfoLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 6, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        addButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 6, widthConstant: 28, heightConstant: 28)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleTapButton(button: UIButton) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        guard let indexPath = self.courseController?.collectionView?.indexPath(for: self) else { return }
        let i = self.courseController?.courses.index(of: self.course!)
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        self.course?.hasFollowed = !self.course!.hasFollowed
        
        self.courseController?.filteredCourses[indexPath.item].hasFollowed = addButton.isSelected
        let values = [courseId: course?.hasFollowed == true ? 1 : 0]
        
        
        
        if addButton.isSelected {
            if i != nil { self.courseController?.courses[i!].hasFollowed = true }
            self.courseController?.followingCourses.append(self.course!)
            
        } else {
            if i != nil { self.courseController?.courses[i!].hasFollowed = false }
            
            if self.courseController?.viewOptionButton?.isSelected == true {
                self.courseController?.followingCourses.remove(at: indexPath.item)
                self.courseController?.filteredCourses.remove(at: indexPath.item)
                self.courseController?.collectionView?.reloadData()
            } else {
                if let j = self.courseController?.followingCourses.index(of: self.course!) {
                    self.courseController?.followingCourses.remove(at: j)
                }
            }
        }
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to edited the course:", err)
                return
            }
            print("Successfully edited the course: ", courseId)
        }
    }
    
    private func setupAddedStyle() {
        addButton.isSelected = true
        addButton.backgroundColor = themeColor
    }
    
    private func setupEmptyStyle() {
        addButton.isSelected = false
        addButton.backgroundColor = UIColor.white
    }
    
    
    
    @objc func handleTapCell() {
        guard let indexPath = courseController?.collectionView?.indexPath(for: self) else { return }
        courseController?.didSelectCellAt(indexPath: indexPath)
    }
    
}






