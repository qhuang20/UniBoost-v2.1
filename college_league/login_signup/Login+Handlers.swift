//
//  Login+Handlers.swift
//  instagram_firebase
//
//  Created by Qichen Huang on 2018-02-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

extension LoginController {
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = themeColor
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = lightThemeColor
        }
    }
    
    
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        self.dontHaveAccountButton.isEnabled = false
        let indicator = getActivityIndicator()
        view.endEditing(true)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err as NSError? {
                print("Failed to sign in with email:", err)
                self.dontHaveAccountButton.isEnabled = true
                indicator.stopAnimating()
                
                if err.code == AuthErrorCode.wrongPassword.rawValue {
                    self.popUpErrorView(text: "Wrong Password", backGroundColor: UIColor.darkGray, topConstant: 100)
                } else if err.code == AuthErrorCode.userNotFound.rawValue {
                    self.popUpErrorView(text: "Invalid Email", backGroundColor: UIColor.darkGray, topConstant: 100)
                } else {
                    self.popUpErrorView(text: "Try it again", backGroundColor: UIColor.darkGray, topConstant: 100)
                }
                
                return
            }
            print("Successfully logged back in with user:", user?.uid ?? "")
            self.passwordTextField.resignFirstResponder()
            
            
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    @objc func handleShowSignUp() {
        let signUpController = SignupController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
}








