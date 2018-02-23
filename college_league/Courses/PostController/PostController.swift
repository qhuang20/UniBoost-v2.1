//
//  PostController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-02-22.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit

class PostController: UIViewController {
    
    let keyboardHeight: CGFloat = 271
    let lineBreakStringForImage = NSAttributedString(string: "\n\n", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)])

    lazy var postTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 20)
        
        let bottomInset = view.safeAreaLayoutGuide.layoutFrame.height - keyboardHeight - 125
        let contentInset = UIEdgeInsets(top: 44, left: 0, bottom: bottomInset, right: 0)
        tv.textContainerInset = contentInset//add scrollView space
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationButtons()
        view.backgroundColor = UIColor.white
        postTextView.becomeFirstResponder()
        view.addSubview(postTextView)
        
        postTextView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: keyboardHeight, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        postTextView.resignFirstResponder()
    }

    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Append", style: .plain, target: self, action: #selector(handleAppend))
    }

}



