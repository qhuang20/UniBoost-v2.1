//
//  PostContentController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-06.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AMScrollingNavbar

class PostContentController: UITableViewController {
    
    var post: Post?
    var postMessages = [PostMessage]()
    
    var responseArr = [Response]()
    var responseMessagesDic = [String: [ResponseMessage]]()
    
    let postHeaderCellId = "postHeaderCellId"
    let postMessageCellId = "postMessageCellId"
    let responseHeaderCellId = "responseHeaderCellId"
    let responseMessageCellId = "responseMessageCellId"
    let cellSpacing: CGFloat = 5
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.showNavbar(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 10, followers: [tabBarController!.tabBar])
        }
        tableView.backgroundColor = brightGray
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 125
        tableView.register(PostHeaderCell.self, forCellReuseIdentifier: postHeaderCellId)
        tableView.register(PostMessageCell.self, forCellReuseIdentifier: postMessageCellId)
        tableView.register(ResponseHeaderCell.self, forCellReuseIdentifier: responseHeaderCellId)
        tableView.register(ResponseMessageCell.self, forCellReuseIdentifier: responseMessageCellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdate), name: ResponseController.updateResponseNotificationName, object: nil)

        fetchPostMessagesResponse()
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return responseArr.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return postMessages.count + 1
        }
        
        let responseId = responseArr[section - 1].responseId
        return responseMessagesDic[responseId]!.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topIndexPath = IndexPath(row: 0, section: 0)
        let section = indexPath.section
        let row = indexPath.row
       
        if indexPath == topIndexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: postHeaderCellId, for: indexPath) as! PostHeaderCell
            cell.post = post
            cell.postContentController = self
            return cell
        }
        
        if section == 0 && row >= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: postMessageCellId, for: indexPath) as! PostMessageCell
            cell.postMessage = postMessages[row - 1]
            return cell
        }
        
        if section >= 1 && row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: responseHeaderCellId, for: indexPath) as! ResponseHeaderCell
            cell.response = responseArr[section - 1]
            return cell
        }
        
        if section >= 1 && row >= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: responseMessageCellId, for: indexPath) as! ResponseMessageCell
            let responseId = responseArr[section - 1].responseId
            cell.responseMessage = responseMessagesDic[responseId]?[row - 1]
            return cell
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let postFooter = PostFooterView()
            postFooter.postContentController = self
            return postFooter
        }
        
        let responseFooter = ResponseFoonterView()
        return responseFooter
    }


    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return cellSpacing
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    
    private func fetchPostMessagesResponse() {
        guard let postId = post?.postId else { return }
        Database.fetchPostMessagesWithPID(pid: postId) { (postMessages) in
            self.postMessages = postMessages
            self.tableView.reloadData()
        }
        
        fetchResponse()
    }
    
    private func fetchResponse() {
        guard let postId = post?.postId else { return }
        let ref = Database.database().reference().child("post_response").child(postId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let responseDic = snapshot.value as? [String: Any] else { return }
            
            responseDic.forEach({ (responseId, num) in
                Database.fetchResponseWithRID(rid: responseId, completion: { (response) in
                    self.responseArr.append(response)

                    Database.fetchResponseMessagesWithRID(rid: responseId) { (responseMessages) in
                        self.responseMessagesDic[responseId] = responseMessages
                        
                        if self.responseMessagesDic.count == responseDic.count {
                            self.responseArr.sort(by: { (p1, p2) -> Bool in
                                return p1.creationDate.compare(p2.creationDate) == .orderedAscending///
                            })
                            self.tableView.reloadData()
                        }
                    }
                })
            })
        }) { (err) in
            print("Failed to fetch post response:", err)
        }
    }
    
    @objc func handleUpdate() {
        responseArr.removeAll()
        fetchResponse()
    }
    
}












