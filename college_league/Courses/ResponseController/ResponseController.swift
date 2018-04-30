//
//  ResponseController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class ResponseController: PostController {
    
    var postId: String?
    
    static let updateResponseNotificationName = NSNotification.Name(rawValue: "UpdateResponse")
    static let updateResponseCountName = NSNotification.Name(rawValue: "UpdateResponseCount")

    static let updateProfileResponseNotificationName = NSNotification.Name(rawValue: "UpdateProfileResponse")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem?.title = "Respond"
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    private func changeResponseCount() {///need to change count: 1.delete response 2.delete post (in course)
        guard let postId = postId else { return }
        let ref = Database.database().reference().child("posts").child(postId).child("response")
        
        ref.runTransactionBlock({ (currentData) -> TransactionResult in
            let currentValue = currentData.value as? Int ?? 0
            currentData.value = currentValue + 1
            
            return TransactionResult.success(withValue: currentData)
        }) { (err, committed, snapshot) in
            if let error = err {
                print("Failed to increase response count", error)
                return
            }
            print("Successfully increased response count")
            
            let userInfo = ["postId": postId, "add": true] as [String : Any]
            NotificationCenter.default.post(name: ResponseController.updateResponseCountName, object: nil, userInfo: userInfo)
        }
    }
    
    override func handlePost() {
        guard let attributedText = postTextView.attributedText, attributedText.length > 0 else { return }
        dismiss(animated: true, completion: nil)
        
        let partsDic = getPartsDictionary()
        uploadImagesToStorage(partsDic: partsDic)
        changeResponseCount()
    }
    
    private func uploadImagesToStorage(partsDic: [Int: Any]) {
        var values = [String: [String: Any]]()
        
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
                let storageRef = Storage.storage().reference().child("response_images")
                storageRef.child(filename).putData(thumbnailData, metadata: nil, completion: { (metadata, err) in
                    if let err = err {
                        print("Failed to upload response thumbnail image:", err)
                        return
                    }
                    
                    storageRef.child(filename).downloadURL { (url, err) in
                        guard let thumbnailUrl = url?.absoluteString else { return }
                        print("Successfully uploaded thumbnail image:", thumbnailUrl)
                        
                        let filename = NSUUID().uuidString
                        storageRef.child(filename).putData(highQualityImageData, metadata: metadata, completion: { (metadata, err) in
                            if let err = err {
                                print("Failed to upload response HQImage:", err)
                                return
                            }
                            
                            storageRef.child(filename).downloadURL(completion: { (url, error) in
                                guard let highQualityImageUrl = url?.absoluteString else { return }
                                print("Successfully uploaded highQ image:", highQualityImageUrl)
                                
                                values[String(count)] = ["imageUrl": highQualityImageUrl, "thumbnailUrl": thumbnailUrl, "imageHeight": imageHeight]
                                
                                if values.count == partsDic.count {
                                    print("Successfully uploaded all response messages")
                                    self.saveToDatabaseWith(properties: values)
                                }
                            })
                        })
                    }
                })
            } else {
                values[String(count)] = ["text": object as! String]
                if values.count == partsDic.count {
                    print("Successfully uploaded all response messages")
                    self.saveToDatabaseWith(properties: values)
                }
            }
        })
    }
    
    private func saveToDatabaseWith(properties: [String: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = postId else { return }
        
        let values: [String: Any] = ["uid": uid, "postId": postId, "creationDate": Date().timeIntervalSince1970, "likes": 0] as [String : Any]
        
        let responseRef = Database.database().reference().child("response").childByAutoId()
        responseRef.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to save response to DB", err)
                return
            }
            let responseId = responseRef.key
            
            let responseMessagesRef = Database.database().reference().child("response_messages")
            let responseMessagesChild = responseMessagesRef.child(responseId)
            responseMessagesChild.updateChildValues(properties)
            
            
            
            let userResponseRef = Database.database().reference().child("user_response")
            let userResponseChild = userResponseRef.child(uid)
            userResponseChild.updateChildValues([responseId: 1])
            
            
            
            let postResponseRef = Database.database().reference().child("post_response").child(postId)
            postResponseRef.updateChildValues([responseId: 1])
            
            print("Yeeeeeaaaaaahhhhhh, Successfully saved response to DB")
            NotificationCenter.default.post(name: ResponseController.updateResponseNotificationName, object: nil)
            NotificationCenter.default.post(name: ResponseController.updateProfileResponseNotificationName, object: nil)
        }
    }
    
}











