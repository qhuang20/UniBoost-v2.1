//
//  WebViewController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-05-10.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    var resourceName: String!
    var resourceType: String = "rtf"
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDismiss))
        
        let path = Bundle.main.path(forResource: resourceName, ofType: resourceType)
        let url = URL(fileURLWithPath: path!)
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}


