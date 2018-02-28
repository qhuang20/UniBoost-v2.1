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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        setupSwitchBar()
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }
    
    private func setupSwitchBar() {
        let switchBar = SwitchBar()
        view.addSubview(switchBar)
        
        switchBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 34)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .green
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = view.safeAreaLayoutGuide.layoutFrame.height
        
        return CGSize(width: width, height: height)
    }
    
}
