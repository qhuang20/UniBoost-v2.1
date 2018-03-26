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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem?.title = "Respond"
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func handlePost() {
        guard let attributedText = postTextView.attributedText, attributedText.length > 0 else { return }
        dismiss(animated: true, completion: nil)
        
        let partsDic = getPartsDictionary()
        uploadImagesToStorage(partsDic: partsDic)
    }
    
    private func uploadImagesToStorage(partsDic: [Int: Any]) {
        var values = [String: [String: Any]]()
        
        partsDic.forEach({ (count, object) in
            if let image = object as? UIImage {
                let thumbnailImage = image.resizeImageTo(width: postTextView.frame.width - 38)
                let imageHeight = thumbnailImage!.size.height
                let highQualityImage = image
                guard let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 0.8) else { return }
                guard let highQualityImageData = UIImageJPEGRepresentation(highQualityImage, 0.8) else { return }
                
                let filename = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("response_images")
                storageRef.child(filename).putData(thumbnailData, metadata: nil, completion: { (metadata, err) in
                    if let err = err {
                        print("Failed to upload response thumbnail image:", err)
                        return
                    }
                    
                    guard let thumbnailUrl = metadata?.downloadURL()?.absoluteString else { return }
                    
                    let filename = NSUUID().uuidString
                    storageRef.child(filename).putData(highQualityImageData, metadata: metadata, completion: { (metadata, err) in
                        if let err = err {
                            print("Failed to upload response HQImage:", err)
                            return
                        }
                        
                        guard let highQualityImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                        values[String(count)] = ["imageUrl": highQualityImageUrl, "thumbnailUrl": thumbnailUrl, "imageHeight": imageHeight]
                        
                        if values.count == partsDic.count {
                            print("Successfully uploaded all response messages")
                            self.saveToDatabaseWith(properties: values)
                        }
                    })
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
        }
    }
    
}











