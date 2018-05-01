//
//  PostsSearchController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-30.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import LBTAComponents
import TRON
import SwiftyJSON
import Alamofire
import Firebase

extension PostsSearchController: UISearchBarDelegate {
    
    @objc func handleSelectedType(recognizer: UITapGestureRecognizer) {
        let selectedView = recognizer.view!
        if selectedView.backgroundColor == typeSelectedColor { return }
        
        typeViews.forEach { (typeView) in
            typeView.backgroundColor = typeUnSelectedColor
        }
        
        selectedView.backgroundColor = typeSelectedColor
    }
    
    
    
    internal func fetchPostIds() {
        let request: APIRequest<Elasticsearch, JsonError> = tron.swiftyJSON.request("/posts/_search")
        request.authorizationRequirement = .none
        request.headerBuilder = HeaderBuilder(defaultHeaders: ["Accept": "application/json", "Authorization": "Basic dXNlcjpmQ212dFI0TktOd3o="])
        
        guard let course = course else { return }
        let school = course.school
        let courseId = course.courseId
        let userSearchInput = ""///
        let type = self.postType
        let searchText = "*\(userSearchInput)* type:\(type) school:\(school) courseId:\(courseId)"//the space equals +
        request.parameters = ["default_operator": "AND", "q": searchText, "size": "30"]///sort=creationDate:desc
        
        request.perform(withSuccess: { (searchResult) in
            print("\nSuccessfully fetch json")
            print("Posts Count: ", searchResult.postIds.count)
            self.postIds = searchResult.postIds
            self.paginatePosts()
            
        }) { (error) in
            print("Fail to fetch json: ", error)
            ///show error label
        }
    }
    
    class JsonError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR")
        }
    }
    
    class Elasticsearch: JSONDecodable {
        
        var postIds = [String]()
        var isFinishedPaging = false
        
        required init(json: JSON) throws {
            let hitsJson = json["hits"]
            let hitsArray = hitsJson["hits"].array
           
            if hitsArray?.count == 0 {
                isFinishedPaging = true
            }
            
            hitsArray?.forEach({ (hit) in
                let postId = hit["_id"].stringValue
                postIds.append(postId)
            })
        }
        
    }
    
    @objc internal func paginatePosts() {
        if postIds.count == 0 {
            self.isFinishedPaging = true
            self.isPaging = false
            self.tableView.reloadData()
            print("no postIds")
            return
        }
        print("\nstart paging")
        let queryNum = 6
        isPaging = true
        var endIndex = queryStartingIndex + queryNum
        if endIndex >= postIds.count - 1 {
            endIndex = postIds.count - 1
            isFinishedPaging = true
        }
        let subPostIds = postIds[queryStartingIndex...endIndex]
        queryStartingIndex = endIndex + 1
        var counter = 0
        
        subPostIds.forEach { (postId) in
            Database.fetchPostWithPID(pid: postId, completion: { (post) in
                self.posts.append(post)
                print("inside:   ", post.postId)
                let dummyImageView = CachedImageView()//preload image
                dummyImageView.loadImage(urlString: post.thumbnailImageUrl ?? "")
                
                counter = counter + 1
                if subPostIds.count == counter {
                    self.isPaging = false
                    self.tableView.reloadData()
                }
            })
        }
    }

    @objc func refresh() {
//        if isPaging { return }
//        postIds.removeAll()
//        posts.removeAll()
//        queryStartingIndex = 0
//        self.isFinishedPaging = false
//        fetchFollowingUserPostIds()
    }
    
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text Did Change")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)//Keyboard Done
    }
    
}






