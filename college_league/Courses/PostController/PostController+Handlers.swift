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
    

    
    internal func getPartsDictionary() -> [Int: Any] {
        var partsDic = [Int: Any]()
        var count = 0
        let parts = postTextView.getParts()
        
        parts.forEach { (object) in
            if let image = object as? UIImage {
                partsDic[count] = image
            }
            if let string = object as? String {
                partsDic[count] = string
            }
            count = count + 1
        }
        
        return partsDic
    }
    
    private func addPostsCount() {
        guard let course = course else { return }
        let school = course.school
        let courseId = course.courseId
        let ref = Database.database().reference().child("school_courses").child(school).child(courseId).child("postsCount")
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = currentValue + 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase post count", error)
                return
            }
            print("Successfully increased post count")
        }
    }
    
    @objc func handlePost() {
        guard let attributedText = postTextView.attributedText, attributedText.length > 0 else {
            popUpErrorView(text: "Please say something 📝")
            return
        }
        dismiss(animated: true, completion: nil)
        
        let partsDic = getPartsDictionary()
        uploadImagesToStorage(partsDic: partsDic)
        addPostsCount()
    }
    
    private func uploadImagesToStorage(partsDic: [Int: Any]) {
        var values = [String: [String: Any]]()
        var postCellThumbnailProperties = [String: Any]()
        var minCount = 10
        
        partsDic.forEach({ (count, object) in
            if let image = object as? UIImage {
                let goalWidth = postTextView.frame.width - 38
                let goalHeight = goalWidth * (image.size.height / image.size.width)
                let thumbnailImage = image.resizeImageTo(width: lqImageWidth)
                let imageHeight = goalHeight
                let highQualityImage = image
                guard let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1) else { return }
                guard let highQualityImageData = UIImageJPEGRepresentation(highQualityImage, 0.8) else { return }
                
                let filename = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("post_images")
                storageRef.child(filename).putData(thumbnailData, metadata: nil, completion: { (metadata, err) in
                    if let err = err {
                        print("Failed to upload post thumbnail image:", err)
                        return
                    }
                   
                    
                    
                    guard let thumbnailUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                    if count < minCount {
                        postCellThumbnailProperties = ["thumbnailImageUrl": thumbnailUrl, "thumbnailImageHeight": imageHeight]
                        minCount = count
                    }
                    
                    let filename = NSUUID().uuidString
                    storageRef.child(filename).putData(highQualityImageData, metadata: metadata, completion: { (metadata, err) in
                        if let err = err {
                            print("Failed to upload post HQImage:", err)
                            return
                        }
                        
                        guard let highQualityImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                        values[String(count)] = ["imageUrl": highQualityImageUrl, "thumbnailUrl": thumbnailUrl, "imageHeight": imageHeight]
                        
                        if values.count == partsDic.count {
                            print("Successfully uploaded all post messages")
                            self.saveToDatabaseWith(properties: values, postCellThumbnailProperties: postCellThumbnailProperties)
                        }
                    })
                })
            } else {
                values[String(count)] = ["text": object as! String]
                if values.count == partsDic.count {
                    print("Successfully uploaded all post messages")
                    self.saveToDatabaseWith(properties: values, postCellThumbnailProperties: postCellThumbnailProperties)
                }
            }
        })
    }

    private func saveToDatabaseWith(properties: [String: Any], postCellThumbnailProperties: [String: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let course = course else { return }
        
        var values: [String: Any] = ["uid": uid, "type": self.postType ?? "Other", "title": self.postTitle ?? "", "creationDate": Date().timeIntervalSince1970, "response": 0, "likes": 0] as [String : Any]
        postCellThumbnailProperties.forEach({values[$0] = $1})
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        postRef.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to save post to DB", err)
                return
            }
            let postId = postRef.key
            
            let postMessagesRef = Database.database().reference().child("post_messages")
            let postMessagesChild = postMessagesRef.child(postId)
            postMessagesChild.updateChildValues(properties)
            
            
            
            let userPostsRef = Database.database().reference().child("user_posts")
            let userPostsChild = userPostsRef.child(uid)
            userPostsChild.updateChildValues([postId: 1])
            
            
            
            let coursePostsRef = Database.database().reference().child("school_course_posts")
            let coursePostsChild = coursePostsRef.child(course.school).child(course.courseId)
            coursePostsChild.updateChildValues([postId: 1])
            
            print("Yeeeeeaaaaaahhhhhh, Successfully saved post to DB")
            NotificationCenter.default.post(name: PostController.updateFeedNotificationName, object: nil)
        }
    }
    
    
    
    internal func insertImage(image: UIImage) {
        let goalWidth = postTextView.frame.width - 38
        let goalHeight = goalWidth * (image.size.height / image.size.width)
        let newImage = image.resizeImageTo(width: hqImageWidth)
        let attachment = NSTextAttachment()
        attachment.image = newImage
        attachment.bounds = CGRect(x: 0, y: 0, width: goalWidth, height: goalHeight)
        
        moveCursorToNextLine()
        postTextView.textStorage.insert(NSAttributedString(attachment: attachment), at: postTextView.selectedRange.location)
        moveCursorRightByOne()
        postTextView.font = UIFont.systemFont(ofSize: textFont)
        moveCursorToNextLine()
    }
    
    private func moveCursorToNextLine() {
        let currentLocation = postTextView.selectedRange.location
        postTextView.textStorage.insert(lineBreakStringForImage, at: currentLocation)
        
        guard let currentPosition = postTextView.selectedTextRange?.start else { return }
        let nextPostion = postTextView.position(from: currentPosition, in: UITextLayoutDirection.right, offset: 2)
        postTextView.selectedTextRange = postTextView.textRange(from: nextPostion!, to: nextPostion!)
    }
    
    private func moveCursorRightByOne() {
        guard let currentPosition = postTextView.selectedTextRange?.start else { return }
        let nextPostion = postTextView.position(from: currentPosition, in: UITextLayoutDirection.right, offset: 1)
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
                DispatchQueue.main.async(execute: {
                    self.popUpErrorView(text: "Please Allow us Access your Photos")
                })
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
