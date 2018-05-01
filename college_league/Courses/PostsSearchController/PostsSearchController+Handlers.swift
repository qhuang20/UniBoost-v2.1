//
//  PostsSearchController+Handlers.swift
//  college_league
//
//  Created by Qichen Huang on 2018-04-30.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON
import Alamofire
import Firebase

extension PostsSearchController: UISearchBarDelegate {
    
    internal func fetchPostIds(withPostType: String) {
        let request: APIRequest<Elasticsearch, JsonError> = tron.swiftyJSON.request("/posts/_search")
        request.authorizationRequirement = .none
        request.headerBuilder = HeaderBuilder(defaultHeaders: ["Accept": "application/json", "Authorization": "Basic dXNlcjpmQ212dFI0TktOd3o="])
        
        guard let course = course else { return }
        let school = course.school
        let courseId = course.courseId
        let userSearchInput = ""
        let type = withPostType
        let searchText = "*\(userSearchInput)* type:\(type) school:\(school) courseId:\(courseId)"//the space equals +
        request.parameters = ["default_operator": "AND", "q": searchText, "size": "30"]///sort=creationDate:desc
        
        request.perform(withSuccess: { (searchResult) in
            print("\nSuccessfully fetch json\n")
            print("Count: ", searchResult.postIds.count)
            
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






