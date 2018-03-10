//
//  PostController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-22.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Photos

class PostController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var course: Course? 

    var postType: String?
    var postTitle: String?
    var thumbnailImage: UIImage?

    var images = [UIImage]()
    var assets = [PHAsset]()
    var insertedImagesMap = [UIImage: UIImage]()

    var collectionViewBottomAnchor: NSLayoutConstraint?
    
    let cellId = "cellId"
    let textFont: CGFloat = 18
    let estimatedKeyboardHeight: CGFloat = 271
    lazy var attributesWithFont = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: textFont)]
    lazy var lineBreakStringForImage = NSAttributedString(string: "\n\n", attributes: attributesWithFont)

    lazy var postTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: textFont)
        tv.textDragInteraction?.isEnabled = false
        
        let bottomInset = view.safeAreaLayoutGuide.layoutFrame.height - estimatedKeyboardHeight - 125
        let contentInset = UIEdgeInsets(top: 85, left: 14, bottom: bottomInset, right: 14)
        tv.textContainerInset = contentInset//add scrollView space
        return tv
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = brightGray
        cv.delegate = self
        cv.dataSource = self

        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        return cv
    }()
    
    let photoButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlTapPhoto), for: .touchUpInside)
        return button
    }()
    
    let keyboardButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "keyboard").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlTapKeyboard), for: .touchUpInside)
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        return aiv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButtons()
        setupKeyboardObservers()
        setupInputAccessoryView()
        view.backgroundColor = UIColor.white
        navigationItem.titleView = activityIndicatorView
        postTextView.becomeFirstResponder()
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)

        view.addSubview(postTextView)
        view.addSubview(collectionView)
        view.addSubview(keyboardButton)

        postTextView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: estimatedKeyboardHeight, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        collectionViewBottomAnchor = collectionView.anchorWithReturnAnchors(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -estimatedKeyboardHeight, rightConstant: 0, widthConstant: 0, heightConstant: estimatedKeyboardHeight)[1]
        
        keyboardButton.anchor(nil, left: nil, bottom: collectionView.topAnchor, right: collectionView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 44, heightConstant: 44)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        postTextView.resignFirstResponder()
    }

    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupInputAccessoryView() {
        let inputContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        inputContainerView.backgroundColor = UIColor.clear
        
        inputContainerView.addSubview(photoButton)
        photoButton.anchor(nil, left: nil, bottom: inputContainerView.bottomAnchor, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 44, heightConstant: 44)
        
        postTextView.inputAccessoryView = inputContainerView
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let selectedAsset = self.assets[index]
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 600, height: 600)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { (image, info) in
            if let selectedImage = image {
                self.insertImage(image: selectedImage)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 8) / 3
        
        return CGSize(width: width, height: width)
    }

}






