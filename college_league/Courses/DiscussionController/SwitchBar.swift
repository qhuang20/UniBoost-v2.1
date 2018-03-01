//
//  SwitchBar.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

let buttonColor = UIColor.lightGray

class SwitchBar: UIView {
    
    var sliderLefrAnchor: NSLayoutConstraint?
    weak var discussionController: DiscussionController?
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    lazy var trendingButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "trending").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setTitle("Trending", for: .normal)
        button.tintColor = buttonColor
        button.setTitleColor(buttonColor, for: .normal)
        button.setTitleColor(themeColor, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleTapTrending), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    lazy var currentButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "current").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setTitle(" Current", for: .normal)
        button.tintColor = themeColor
        button.setTitleColor(buttonColor, for: .normal)
        button.setTitleColor(themeColor, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleTapCurrent), for: .touchUpInside)
        button.isSelected = true
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let buttons = [currentButton, trendingButton]
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.axis = .horizontal
        return sv
    }()
    
    let slider: UIView = {
        let sv = UIView()
        sv.backgroundColor = themeColor
        return sv
    }()
    
    private func setupView() {
        self.backgroundColor = UIColor.white
        addSubview(stackView)
        addSubview(slider)
        
        stackView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        sliderLefrAnchor = slider.anchorWithReturnAnchors(nil, left: leftAnchor, bottom: stackView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 2)[0]
        slider.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
    }
    
    
    
    @objc func handleTapCurrent() {
        let indexPath = IndexPath(item: 0, section: 0)
        discussionController?.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
        currentButton.isSelected = true
        currentButton.tintColor = themeColor
        trendingButton.isSelected = false
        trendingButton.tintColor = buttonColor
    }
    
    @objc func handleTapTrending() {
        let indexPath = IndexPath(item: 1, section: 0)
        discussionController?.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
        trendingButton.isSelected = true
        trendingButton.tintColor = themeColor
        currentButton.isSelected = false
        currentButton.tintColor = buttonColor
    }
   
}

