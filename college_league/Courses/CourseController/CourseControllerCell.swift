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
            setupEmptyStyle()
            setupAttributedTitle()
            course?.hasFollowed == true ? setupAddedStyle() : setupEmptyStyle()
        }
    }
    
    weak var courseController: CourseController?
    
    let attributesForTitle = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20.5)]
    let attributesForDescription = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 11.5), NSAttributedStringKey.foregroundColor: UIColor.lightGray]

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
        
        addSubview(courseInfoLabel)
        addSubview(addButton)
        
        courseInfoLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 6, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        addButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 28, heightConstant: 28)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc func handleTapButton(button: UIButton) {///check logic!!!
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let school = course?.school else { return }
        guard let courseId = course?.courseId else { return }
        guard let indexPath = self.courseController?.collectionView?.indexPath(for: self) else { return }
        let ref = Database.database().reference().child("user_courses").child(currentLoggedInUserId).child(school)
        
        let values = [courseId: course?.hasFollowed == true ? 0 : 1]
        ref.updateChildValues(values) { (err, ref) in
            print("Successfully edited the course: ", courseId)
            
            self.course?.hasFollowed = !(self.course!.hasFollowed)
            if let i = self.courseController?.courses.index(of: self.course!) {//Equatable
                self.courseController?.courses[i] = self.course!
            }
            
            if self.course?.hasFollowed == true {///fix UI reaction speed, also fix others
                self.setupAddedStyle()
                self.courseController?.followingCourses.append(self.course!)
            } else {
                self.setupEmptyStyle()
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
        }
    }
    
    @objc func handleTapCell() {
        guard let indexPath = courseController?.collectionView?.indexPath(for: self) else { return }
        courseController?.didSelectCellAt(indexPath: indexPath)
    }
    
    private func setupAddedStyle() {
        addButton.setTitle("✓", for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.backgroundColor = themeColor
    }
    
    private func setupEmptyStyle() {
        addButton.setTitle(" ", for: .normal)
        addButton.backgroundColor = UIColor.white
    }
    
}






