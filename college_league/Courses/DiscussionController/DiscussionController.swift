//
//  DiscussionController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class DiscussionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    let switchBar = SwitchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        configureNavigationBar()
        collectionView?.register(DiscussionCell.self, forCellWithReuseIdentifier: cellId)
        
        switchBar.discussionController = self
        view.addSubview(switchBar)
        
        switchBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.isPagingEnabled = true
        collectionView?.contentInset = UIEdgeInsets(top: 34 + 26, left: 0, bottom: 0, right: 0)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }
    
    private func configureNavigationBar() {
        let button = UIButton(type: .custom)
        let image = #imageLiteral(resourceName: "post").withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.setTitle("Post", for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        button.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc func handlePost() {
        let navTitleTypeController = UINavigationController(rootViewController: TitleTypeController())
        present(navTitleTypeController, animated: true, completion: nil)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = view.safeAreaLayoutGuide.layoutFrame.height
        
        return CGSize(width: width, height: height)
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switchBar.sliderLefrAnchor?.constant = scrollView.contentOffset.x / 2
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        if index == 0 {
            switchBar.currentButton.isSelected = true
            switchBar.currentButton.tintColor = themeColor
            switchBar.trendingButton.isSelected = false
            switchBar.trendingButton.tintColor = buttonColor
        } else {
            switchBar.currentButton.isSelected = false
            switchBar.currentButton.tintColor = buttonColor
            switchBar.trendingButton.isSelected = true
            switchBar.trendingButton.tintColor = themeColor
        }
        
    }
    
}





