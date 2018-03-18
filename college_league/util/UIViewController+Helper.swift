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
        self.view.endEditing(true)
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
    
}
