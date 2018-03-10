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
    
    
    
    private func getHQImagesDictionary() -> [String: UIImage] {
        var imagesDic = [String: UIImage]()
        var count = 0
        let exsitingImages = postTextView.getImages()
        
        exsitingImages.forEach { (image) in
            if count == 0 {
                thumbnailImage = image
            }
            
            if let highQualityImage = insertedImagesMap[image] {
                imagesDic[String(count)] = highQualityImage
                count = count + 1
            }
        }
        
        return imagesDic
    }
    
    @objc func handlePost() {
        guard let attributedText = postTextView.attributedText, attributedText.length > 0 else { return }///
        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd]
        guard let rtfdData = try? attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: documentAttributes) else {return}
       
        //dismiss(animated: true, completion: nil)///
        
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        activityIndicatorView.startAnimating()
        
        let optimizedRtfData: Data = try! rtfdData.gzipped(level: .bestCompression)
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(optimizedRtfData, metadata: nil) { (metadata, err) in

            if let err = err {
                self.navigationItem.setHidesBackButton(false, animated: true)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                print("Failed to upload rtfd data:", err)
                return
            }

            guard let rtfdUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post rtfd data")
            
            self.uploadImagesToStorage(rtfdUrl: rtfdUrl)
        }
    }
    
    private func uploadImagesToStorage(rtfdUrl: String) {
        var imageUrlsDic = [String: String]()
        let imagesDic = self.getHQImagesDictionary()
        
        imagesDic.forEach({ (count, image) in
            let newImage = image.resizeImageTo(width: 600)
            guard let uploadData = UIImageJPEGRepresentation(newImage!, 1) else { return }
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("post_images").child(filename)
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to upload post image:", err)
                    return
                }
                
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
                imageUrlsDic[count] = imageUrl
                
                if imageUrlsDic.count == imagesDic.count {
                    print("Successfully uploaded all post images")
                    self.uploadThumbnailImageToStorage(rtfdUrl: rtfdUrl, imageUrlsDic: imageUrlsDic)
                }
            })
        })
        
        if imagesDic.count == 0 {
            self.saveToDatabaseWith(rtfdUrl: rtfdUrl)
        }
    }
    
    private func uploadThumbnailImageToStorage(rtfdUrl: String, imageUrlsDic: [String: String]) {
        guard let thumbnailImage = thumbnailImage else { return }
        guard let uploadData = UIImageJPEGRepresentation(thumbnailImage, 1) else { return }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_thumbnail").child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Failed to upload post thumbnail:", err)
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded post thumbnail")
            
            self.saveToDatabaseWith(rtfdUrl: rtfdUrl, imageUrlsDic: imageUrlsDic, thumbnailUrl: imageUrl)
        }
    }

    private func saveToDatabaseWith(rtfdUrl: String, imageUrlsDic: [String: String] = [:], thumbnailUrl: String = "") {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let course = course else { return }
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let values = ["thumbnailUrl": thumbnailUrl, "rtfdUrl": rtfdUrl, "imageUrls": imageUrlsDic, "uid": uid, "type": self.postType ?? "Other", "title": self.postTitle ?? "", "creationDate": Date().timeIntervalSince1970, "comments": 0, "likes": 0] as [String : Any]
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
            let userPostsChild = userPostsRef.child(uid)
            userPostsChild.updateChildValues([postId: 1])
            
            
            
            let coursePostsRef = Database.database().reference().child("school_course_posts")
            let coursePostsChild = coursePostsRef.child(course.school).child(course.courseId)
            coursePostsChild.updateChildValues([postId: 1])
            
            print("Yeeeeeaaaaaahhhhhh, Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    internal func insertImage(image: UIImage) {
        let goalWidth = postTextView.frame.width - 38
        let newImage = image.resizeImageTo(width: goalWidth)
        let attachment = NSTextAttachment()
        attachment.image = newImage
        insertedImagesMap[newImage!] = image
        
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
