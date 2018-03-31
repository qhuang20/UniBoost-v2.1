//
//  EditProfileController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension EditProfileController: UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSave() {///check valid
        guard let username = nameTextField.text else { return }
        guard let image = self.profileImageView.image else { return }
        let bio = bioTextView.text
        let saveButton = navigationItem.rightBarButtonItem
        saveButton?.tintColor = brightGray
        saveButton?.isEnabled = false
        view.endEditing(true)
        
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
            print("Successfully uploaded profile image:", profileImageUrl)
            
            
            
            let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "bio": bio as Any] as [String : Any]
            self.updateUsersValuesToDatabase(values: dictionaryValues)
        })
    }
    
    private func updateUsersValuesToDatabase(values: [String: Any]) {
        guard let uid = user?.uid else { return }
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
            print("Successfully saved user info to db")
            
            
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleCanel() {
        view.endEditing(true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func handleSetSchool() {
        let setSchoolController = SetSchoolController()
        setSchoolController.modalPresentationStyle = .overFullScreen
        setSchoolController.modalTransitionStyle = .crossDissolve
        present(setSchoolController, animated: true, completion: nil)
    }
    
    
    
    @objc func handleSelectProfileImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        textCountLabel.text = "\(wordsLimitForBio - textView.text.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
}

