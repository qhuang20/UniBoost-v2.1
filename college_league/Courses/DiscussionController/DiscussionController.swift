//
//  DiscussionController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-27.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class DiscussionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var course: Course?
    var searchBar: UISearchBar?
    var searchBarAnchors: [NSLayoutConstraint]?
    var postBarButtonItem: UIBarButtonItem?

    let switchBar = SwitchBar()
    let switchBarHeight: CGFloat = 34
    lazy var edgeInsetTopValue: CGFloat = switchBarHeight - 4
    
    let cellId = "cellId"
    let trendingCellId = "trendingCellId"
    var oneTimeFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionVeiw()
        configureNavigationBar()
        
        collectionView?.register(DiscussionCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(TrendingCell.self, forCellWithReuseIdentifier: trendingCellId)
        
        view.addSubview(switchBar)
        switchBar.discussionController = self
        switchBar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: switchBarHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar?.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutSearchBar()
    }//no super to prevent weird behavior
    
    override func viewDidAppear(_ animated: Bool) { self.searchBar?.alpha = 1 }

    private func layoutSearchBar() {
        searchBar?.showsCancelButton = false
        searchBar?.text = ""
        searchBar?.placeholder = "Find Post"
        guard let searchBarAnchors = searchBarAnchors else { return }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            searchBarAnchors[0].constant = 50
            searchBarAnchors[2].constant = -85
        }, completion: nil)
    }
    
    private func configureCollectionVeiw() {
        collectionView?.backgroundColor = brightGray
        collectionView?.isPagingEnabled = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.contentInset = UIEdgeInsets(top: edgeInsetTopValue, left: 0, bottom: 0, right: 0)
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
        postBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = postBarButtonItem
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier = cellId
        
        if indexPath.item == 1 {
            cellIdentifier = trendingCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! DiscussionCell
        
        cell.course = course
        
        if oneTimeFlag {
            cell.discussionController = self
            oneTimeFlag = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = view.safeAreaLayoutGuide.layoutFrame.height - edgeInsetTopValue
        
        return CGSize(width: width, height: height)
    }
    
    
    
    var firstPreviousSearchText: String = ""
    var secondPreviousSearchText: String = ""
    var previousIndex: CGFloat = 0
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switchBar.sliderLefrAnchor?.constant = scrollView.contentOffset.x / 2
        
        let index = scrollView.contentOffset.x / view.frame.width
        
        //cellForItemAt won't get called every time if the cell is not reused
        if index == 0 && index != previousIndex {
            let indexPath = IndexPath(item: Int(index), section: 0)
            let cell = collectionView?.cellForItem(at: indexPath) as? DiscussionCell
            cell?.discussionController = self
            secondPreviousSearchText = searchBar?.text ?? ""
            searchBar?.text = firstPreviousSearchText
            searchBar?.resignFirstResponder()
            previousIndex = index
            
        } else if index == 1 && index != previousIndex {
            
            let indexPath = IndexPath(item: Int(index), section: 0)
            let cell = collectionView?.cellForItem(at: indexPath) as? DiscussionCell
            cell?.discussionController = self
            firstPreviousSearchText = searchBar?.text ?? ""
            searchBar?.text = secondPreviousSearchText
            searchBar?.resignFirstResponder()
            previousIndex = index
        }
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
    
    
    
    @objc func handlePost() {
        let titleTypeController = TitleTypeController()
        let navTitleTypeController = UINavigationController(rootViewController: titleTypeController)
        titleTypeController.course = course
        
        present(navTitleTypeController, animated: true, completion: nil)
    }
    
}






