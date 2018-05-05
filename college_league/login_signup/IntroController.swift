//
//  IntroController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-29.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents

struct Page {
    var message: String
    var image: UIImage
}

class IntroController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    let sideConstantForButton: CGFloat = 35
    
    let pages: [Page] = {
        let firstPage = Page(message: "Sharing your knowledge \n with the world", image: #imageLiteral(resourceName: "page1"))
        
        let secondPage = Page(message: "Sharing will enrich everyone \n with more knowledge", image: #imageLiteral(resourceName: "page4"))
        
        let thirdPage = Page( message: "In teaching others \n we teach ourselves", image: #imageLiteral(resourceName: "page3"))
        
        return [firstPage, secondPage, thirdPage]
    }()
    
    lazy var guestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login as a Guest", for: .normal)
        button.backgroundColor = UIColor(r: 148, g: 209, b: 134)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleGuest), for: .touchUpInside)
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = themeColor
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        pc.numberOfPages = self.pages.count
        return pc
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        configureCollectionView()
        
        view.addSubview(pageControl)
        view.addSubview(getStartedButton)
        view.addSubview(loginButton)
        view.addSubview(guestButton)
        
        pageControl.anchor(nil, left: view.leftAnchor, bottom: guestButton.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        guestButton.anchor(nil, left: view.leftAnchor, bottom: getStartedButton.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: sideConstantForButton, bottomConstant: 10, rightConstant: sideConstantForButton, widthConstant: 0, heightConstant: 40)
        getStartedButton.anchor(nil, left: view.leftAnchor, bottom: loginButton.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: sideConstantForButton, bottomConstant: 10, rightConstant: sideConstantForButton, widthConstant: 0, heightConstant: 40)
        loginButton.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: sideConstantForButton, bottomConstant: 30, rightConstant: sideConstantForButton, widthConstant: 0, heightConstant: 40)
    }
    
    private func configureCollectionView() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView?.backgroundColor = UIColor(r: 43, g: 66, b: 94)
        collectionView?.isPagingEnabled = true
        collectionView?.register(PageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        cell.page = pages[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumber
    }
    
    
    
    @objc private func handleLogin() {
        print("Go to Login")
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc private func handleSignup() {
        print("Go to Signup")
        let signupController = SignupController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc private func handleGuest() {
        print("Go to Signup")
        let signupController = SignupController()
        navigationController?.pushViewController(signupController, animated: true)
        
        let randomEmail = NSUUID().uuidString
        signupController.emailTextField.text = "guest-" + randomEmail + "@guest.com"
        signupController.usernameTextField.text = "Guest"
        signupController.passwordTextField.text = "qqqqqq"
        signupController.handleSignUp()
    }
    
}














