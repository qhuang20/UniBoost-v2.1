//
//  ViewController+Helper.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-17.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

extension UIViewController {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if view.isFirstResponder {//useless
            self.view.endEditing(true)
            print("UIViewController: endEditing")
        }
    }
    
    
    
    internal func popUpErrorView(text: String, backGroundColor: UIColor = UIColor.orange, topConstant: CGFloat = 0) {
        let errorView = createErrorView(text: text, color: backGroundColor, fontSize: 16)
        view.addSubview(errorView)
        
        if topConstant == 0 {
            errorView.anchorCenterXToSuperview()
            errorView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: (view.safeAreaLayoutGuide.layoutFrame.height / 2) - 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            errorView.anchorCenterXToSuperview()
            errorView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: topConstant, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }

        UIView.animate(withDuration: 1, delay: 1.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            errorView.alpha = 0
            
        }, completion: { (didComplete) in
            errorView.removeFromSuperview()
        })
    }
    
    private func createErrorView(text: String, color: UIColor, fontSize: CGFloat) -> UILabel {
        let label = PaddingLabel()
        label.text = text
        label.backgroundColor = color
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textColor = .white
        
        return label
    }
    
    
    
    internal func getActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.hidesWhenStopped = true
        
        view.addSubview(indicator)
        indicator.anchorCenterSuperview()
        
        indicator.startAnimating()
        return indicator
    }
    
    
    
    internal func observeKeyboardShowHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 100
            }
            
        }, completion: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 100
            }
            
        }, completion: nil)
    }
    
}

//    func hideKeyboardWhenTappedAround() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }





