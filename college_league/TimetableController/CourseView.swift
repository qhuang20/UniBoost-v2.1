//
//  CourseStackView.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseView: UIView {
    
    var courseInfo: CourseInfo
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(courseInfo: CourseInfo) {
        self.courseInfo = courseInfo
        super.init(frame: .zero)
        setupView()
    }
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.axis = .vertical
        return sv
    }()
    
    private func createLabel(text: String, color: UIColor, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = color
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        label.textAlignment = .center
        label.textColor = .white
        
        label.numberOfLines = 3
        return label
    }

    private func setupView() {
        self.backgroundColor = courseInfo.color
        self.layer.cornerRadius = 8
        clipsToBounds = true

        addSubview(stackView)
        stackView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)//text has intrinsic size
        
        if courseInfo.title.count > 0 {
            let titleLabel = createLabel(text: courseInfo.title, color: courseInfo.color, fontSize: 14)
            stackView.addArrangedSubview(titleLabel)
        }
        
        if courseInfo.place.count > 0 {
            let placeLabel = createLabel(text: courseInfo.place, color: courseInfo.color, fontSize: 13)
            stackView.addArrangedSubview(placeLabel)
        }

        if courseInfo.note.count > 0 {
            let noteLabel = createLabel(text: courseInfo.note, color: courseInfo.color, fontSize: 12)
            stackView.addArrangedSubview(noteLabel)
        }

    }
    
}






