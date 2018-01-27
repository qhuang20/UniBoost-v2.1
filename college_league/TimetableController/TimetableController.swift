//
//  ViewController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-24.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

let columes: CGFloat = 5
let sideBarWidth: CGFloat = 36
let daysBarHeight: CGFloat = 36

class TimetableController: DatasourceController {

    lazy var daysBar: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.backgroundColor = .red
        return cv
    }()
    
    let sideBar: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.backgroundColor = .green
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = TimetableDatasource()
        navigationItem.title = "TimeTable"

        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.5
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = brightGray

        collectionView?.contentInset = UIEdgeInsets(top: 0, left: sideBarWidth, bottom: 0, right: 0)

        setupBars()
    }
    
    private func setupBars() {
        view.addSubview(sideBar)
        view.addSubview(daysBar)
        
        sideBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: sideBarWidth, heightConstant: 0)
        daysBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: sideBar.safeAreaLayoutGuide.rightAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: daysBarHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = view.safeAreaLayoutGuide.layoutFrame.height
        let width = (view.safeAreaLayoutGuide.layoutFrame.width - sideBarWidth) / columes
        
        return CGSize(width: width, height: height)
    }

}


