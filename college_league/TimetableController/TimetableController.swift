//
//  ViewController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-01-24.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import LBTAComponents

let hoursBarWidth: CGFloat = 36
let daysBarHeight: CGFloat = 36
let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
let hours = ["8", "9", "10", "11", "12", "1", "2", "3", "4", "5", "6", "7"]

class TimetableController: DatasourceController {
    
    let daysBar: UIStackView = {
        var views = [UIView]()
        for i in 0...weekdays.count - 1 {
            let label = UILabel()
            label.backgroundColor = brightGray
            label.text = weekdays[i]
            label.textAlignment = .center
            views.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: views)
        sv.distribution = .fillEqually
        return sv
    }()
    
    let hoursBar: UIStackView = {
        var views = [UIView]()
        for i in 0...11 {
            let label = UILabel()
            label.backgroundColor = brightGray
            label.text = hours[i]
            label.textAlignment = .center
            views.append(label)
        }
        
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.layer.cornerRadius = 10
        sv.clipsToBounds = true
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasource = TimetableDatasource()
        
        configureNavigationItems()
        
        configureCollectionView()

        setupTimeBars()
    }
    
    private func configureNavigationItems() {
        navigationItem.title = "TimeTable"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNewCourse))
    }
    
    private func configureCollectionView() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.5
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = brightGray
        
        collectionView?.contentInset = UIEdgeInsets(top: daysBarHeight, left: hoursBarWidth, bottom: 0, right: 0)
    }
    
    private func setupTimeBars() {
        view.addSubview(hoursBar)
        view.addSubview(daysBar)
        
        hoursBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: hoursBarWidth, heightConstant: 0)
        daysBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: hoursBar.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: daysBarHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = view.safeAreaLayoutGuide.layoutFrame.height - daysBarHeight
        let width = (view.frame.width - hoursBarWidth) / CGFloat(weekdays.count)
        
        return CGSize(width: width, height: height)
    }

}


