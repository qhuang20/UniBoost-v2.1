//
//  CourseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class CourseController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        navigationItem.title = "Courses"
        collectionView?.register(CourseControllerCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.contentInset = UIEdgeInsets(top: 12, left: 8, bottom: 0, right: 8)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
     
        let width = (view.frame.width - 12 - 16) / 3
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let discussionController = DiscussionController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(discussionController, animated: true)
    }
    
}



