//
//  Signup+Handlers.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-15.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension SignupController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = themeColor
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = lightThemeColor
        }
    }
    
    
    
    @objc func handleSignUp() {
        view.endEditing(true)
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        guard let image = self.profileImageView.image else { return }
        self.alreadyHaveAccountButton.isEnabled = false
        self.signUpButton.isEnabled = false
        self.addPhotoButton.isEnabled = false
        let indicator = getActivityIndicator()
        view.endEditing(true)
    
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
           
            if let err = error as NSError? {
                self.alreadyHaveAccountButton.isEnabled = true
                self.signUpButton.isEnabled = true
                self.addPhotoButton.isEnabled = true
                indicator.stopAnimating()
                
                if err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.popUpErrorView(text: "Email Already In Use", backGroundColor: UIColor.darkGray, topConstant: 20)
                } else if err.code == AuthErrorCode.invalidEmail.rawValue {
                    self.popUpErrorView(text: "Invalid Email", backGroundColor: UIColor.darkGray, topConstant: 20)
                } else if err.code == AuthErrorCode.weakPassword.rawValue {
                    self.popUpErrorView(text: "Weak Password", backGroundColor: UIColor.darkGray, topConstant: 20)
                } else {
                    self.popUpErrorView(text: "Weak Internet, Try it again", backGroundColor: UIColor.darkGray, topConstant: 20)
                }
                
                print("Failed to create user:", err)
                return
            }
            print("Successfully created user:", user?.uid ?? "")
            
            
            
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile image:", err)
                    return
                }
            
                storageRef.downloadURL { (url, err) in
                    guard let profileImageUrl = url?.absoluteString else { return }
                    print("Successfully uploaded profile image:", profileImageUrl)
                    
                    guard let uid = user?.uid else { return }
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "likes": 0, "followers": 0, "following": 0] as [String : Any]
                    let values = [uid: dictionaryValues]
                    
                    self.updateUsersValuesToDatabase(values: values)
                }
            })
        })
    }
    
    private func updateUsersValuesToDatabase(values: [String: Any]) {
        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            
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
    
    
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
}


