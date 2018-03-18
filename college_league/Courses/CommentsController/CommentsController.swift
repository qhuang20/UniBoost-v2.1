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
    
    let cellId = "cellId"
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "@\(response?.user.username ?? "")"
        return textField
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(themeColor, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.anchor(containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
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
        
        fetchComments()
    }
    
    private func fetchComments() {
        guard let responseId = self.response?.responseId else { return }
        let ref = Database.database().reference().child("response_comments").child(responseId)
        ref.observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            guard let toUid = dictionary["toUid"] as? String else { return }
            
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                Database.fetchUserWithUID(uid: toUid, completion: { (toUser) in
                    let comment = Comment(user: user, toUser: toUser, dictionary: dictionary)
                    self.comments.append(comment)
                    self.collectionView?.reloadData()
                })
            })
        }) { (err) in
            print("Failed to observe comments")
        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        cell.commentsController = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    
    @objc func handleSend() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let toUid = toUser?.uid else { return }
        let responseId = self.response?.responseId ?? ""
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid, "toUid": toUid] as [String : Any]
        let ref = Database.database().reference().child("response_comments").child(responseId).childByAutoId()
        commentTextField.text = nil
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to insert comment:", err)
                return
            }
            print("Successfully inserted comment.")
        }
    }
    
    @objc func handleTapNavBar() {
        commentTextField.becomeFirstResponder()
    }
  
}









