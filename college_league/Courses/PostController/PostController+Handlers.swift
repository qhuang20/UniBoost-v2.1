//
//  PostController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Photos
import Firebase
import Gzip

extension PostController {
    
    internal func fetchPhotos() {
        images.removeAll()
        assets.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 99
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 125, height: 125)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.deliveryMode = .opportunistic
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    
                })
            })
        }
    }
    

    
    @objc func handlePost() {
        guard let attributedText = postTextView.attributedText, attributedText.length > 0 else { return }
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd]
        guard let rtfdData = try? attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: documentAttributes) else {return}
        let optimizedRtfData: Data = try! rtfdData.gzipped(level: .bestCompression)
        
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        activityIndicatorView.startAnimating()
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(optimizedRtfData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.setHidesBackButton(false, animated: true)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                print("Failed to upload post image:", err)
                return
            }
            
            guard let rtfdUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post image:", rtfdUrl)
            
            self.saveToDatabaseWith(rtfdUrl: rtfdUrl)
        }
        
    }
    
    private func saveToDatabaseWith(rtfdUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let values = ["rtfdUrl": rtfdUrl, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        postRef.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.setHidesBackButton(false, animated: true)
                self.activityIndicatorView.stopAnimating()
                print("Failed to save post to DB", err)
                return
            }
            
            let postId = postRef.key
            let userPostsRef = Database.database().reference().child("user_posts")
            let childRef = userPostsRef.child(uid)
            childRef.updateChildValues([postId: 1])
            
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    internal func insertImage(image: UIImage) {
        let attachment = NSTextAttachment()
        attachment.image = image
        let goalWidth = postTextView.frame.width - 38
        let goalHeight = goalWidth * (image.size.height / image.size.width)
        attachment.bounds = CGRect(x: 0, y: 0, width: goalWidth, height: goalHeight)
        
        moveCursorToNextLine()
        postTextView.textStorage.insert(NSAttributedString(attachment: attachment), at: postTextView.selectedRange.location)
        moveCursorRightByOne()
        postTextView.font = UIFont.systemFont(ofSize: 20)
        moveCursorToNextLine()
    }
    
    private func moveCursorToNextLine() {
        let currentLocation = postTextView.selectedRange.location
        postTextView.textStorage.insert(lineBreakStringForImage, at: currentLocation)
        
        let currentPosition = postTextView.selectedTextRange?.start
        let nextPostion = postTextView.position(from: currentPosition!, in: UITextLayoutDirection.right, offset: 2)
        postTextView.selectedTextRange = postTextView.textRange(from: nextPostion!, to: nextPostion!)
    }
    
    private func moveCursorRightByOne() {
        let currentPosition = postTextView.selectedTextRange?.start
        let nextPostion = postTextView.position(from: currentPosition!, in: UITextLayoutDirection.right, offset: 1)
        postTextView.selectedTextRange = postTextView.textRange(from: nextPostion!, to: nextPostion!)
    }
    
    
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        collectionViewBottomAnchor?.constant = keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        collectionViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handlTapPhoto() {
        PHPhotoLibrary.requestAuthorization({status in
            if status == PHAuthorizationStatus.denied {
                ///dispatch and do some uistuff...
                return
            }
        })
    
        postTextView.resignFirstResponder()
        fetchPhotos()
    }
    
    @objc func handlTapKeyboard() {
        postTextView.becomeFirstResponder()
    }
    
}
