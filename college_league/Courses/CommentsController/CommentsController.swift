//
//  CommentsController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var response: Response?
    lazy var toUser: User? = response?.user
    
    var comments = [Comment]()
    var isFinishedPaging = false
    var isPaging = false
    var queryEndingValue = ""
    var scrollToBottomOneTimeFlag = true
    var firstNewCommentOneTimeFlag = false
    var newCommentRef: DatabaseReference?
    
    let cellId = "cellId"
    let loadingCellId = "loadingCellId"
    let loadingCellHeight: CGFloat = 50
    
    lazy var commentTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.placeholderLabel.text = "@\(response?.user.username ?? "")"
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    lazy var sendButton: UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(themeColor, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return sendButton
    }()
    
    lazy var containerView: CustomInputAccessoryView = {
        let containerView = CustomInputAccessoryView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        containerView.addSubview(sendButton)
        sendButton.anchor(containerView.topAnchor, left: nil, bottom: containerView.safeAreaLayoutGuide.bottomAnchor, right: containerView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
        containerView.addSubview(self.commentTextView)
        self.commentTextView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        containerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        if newCommentRef == nil {
            fetchNewComment()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: loadingCellId)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        self.extendedLayoutIncludesOpaqueBars = true
      
        paginateComments()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        newCommentRef?.removeAllObservers()
        newCommentRef = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = comments.count
        return isFinishedPaging ? count : count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isLoadingIndexPath(indexPath) {
            return CGSize(width: view.frame.width, height: loadingCellHeight)
        }
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = isFinishedPaging ? comments[indexPath.item] : comments[indexPath.item - 1]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoadingIndexPath(indexPath) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadingCellId, for: indexPath) as! CollectionViewLoadingCell
            cell.isTheEnd = isFinishedPaging
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = isFinishedPaging ? comments[indexPath.item] : comments[indexPath.item - 1]
        cell.commentsController = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    

    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let offset = collectionView?.contentOffset.y else { return }
        if offset <= 0 && !isFinishedPaging && !isPaging {
            paginateComments()
        }
    }
    
    private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
        guard !isFinishedPaging else { return false }
        return indexPath.item == 0
    }
    
    internal func scrollToBottom() {
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        if !isPaging {
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

}









