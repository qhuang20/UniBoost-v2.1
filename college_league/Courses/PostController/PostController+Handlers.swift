//
//  PostController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-23.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Photos

extension PostController {
    
    internal func fetchPhotos() {
        images.removeAll()
        assets.removeAll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1000
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
    
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePost() {
        print("post....")
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
        postTextView.resignFirstResponder()
        fetchPhotos()
    }
    
    @objc func handlTapKeyboard() {
        postTextView.becomeFirstResponder()
    }
    
}
