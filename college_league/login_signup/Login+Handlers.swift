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
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err {///
                print("Failed to sign in with email:", err)
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
