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
    
    @objc func handleSelectedSortOption(recognizer: UITapGestureRecognizer) {
        if isPaging { return }
        let selectedView = recognizer.view! as! UILabel
        hideSortContainer()
        if selectedView.textColor == sortSelectedColor { return }
        
        sortOptionViews.forEach { (sortLabel) in
            (sortLabel as! UILabel).textColor = sortUnSelectedColor
        }
        selectedView.textColor = sortSelectedColor
        
        if selectedView.text == sortOptionsTexts[0] {
            sortOption = SortOption.creationDate.rawValue
        } else if selectedView.text == sortOptionsTexts[1] {
            sortOption = SortOption.likes.rawValue
        } else {
            sortOption = SortOption.response.rawValue
        }
        
        refresh()
    }
    
    @objc func handleSelectedType(recognizer: UITapGestureRecognizer) {
        if isPaging { return }
        let selectedView = recognizer.view!
        if selectedView.backgroundColor == typeSelectedColor { return }
        
        typeViews.forEach { (typeView) in
            typeView.backgroundColor = typeUnSelectedColor
        }
        selectedView.backgroundColor = typeSelectedColor
        
        let tag = selectedView.tag
        if tag == 0 {
            postType = SearchType.all.rawValue
        } else {
            postType = postTypes[tag - 1]
        }
        
        refresh()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isPaging { return }
        searchBar.endEditing(true)//Keyboard Search
        enableCancelButton(searchBar: searchBar)
        refresh()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text Did Change")
        if searchText.count == 0 {
            if isPaging { return }
            refresh()
        }
    }
    
    
    
    internal func fetchPostIds() {
        let request: APIRequest<Elasticsearch, JsonError> = tron.swiftyJSON.request("/posts/_search")
        request.authorizationRequirement = .none
        request.headerBuilder = HeaderBuilder(defaultHeaders: ["Accept": "application/json", "Authorization": "Basic dXNlcjpmQ212dFI0TktOd3o="])
        
        guard let course = course else { return }
        let school = course.school
        let courseId = course.courseId
        let userSearchInput = searchBar.text ?? ""
        let type = self.postType
        let sortOption = self.sortOption
        let searchText = "*\(userSearchInput)* type:\(type) school:\(school) courseId:\(courseId)"//the space equals +
        request.parameters = ["default_operator": "AND", "q": searchText, "size": "30", "sort": "\(sortOption):desc"]
        
        request.perform(withSuccess: { (searchResult) in
            print("\nSuccessfully fetch json")
            print("Posts Count: ", searchResult.postIds.count)
            self.postIds = searchResult.postIds
            self.paginatePosts()
            
        }) { (error) in
            print("*******************Fail to fetch json: ", error)
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
        
        required init(json: JSON) throws {
            let hitsJson = json["hits"]
            let hitsArray = hitsJson["hits"].array
            
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
            print("\nNo PostIds!!!!!!!!!!!")
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
                    
                    if self.sortOption == SortOption.creationDate.rawValue {
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.creationDate.compare(p2.creationDate) == ComparisonResult.orderedDescending
                        })
                    } else if self.sortOption == SortOption.likes.rawValue {
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.likes > p2.likes
                        })
                    } else {
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.response > p2.response
                        })
                    }
                    
                    self.tableView.reloadData()
                }
            })
        }
    }

    private func refresh() {
        if isPaging { return }
        postIds.removeAll()
        posts.removeAll()
        queryStartingIndex = 0
        self.isFinishedPaging = false
        self.isPaging = true//prevent paginatePosts get triggered by willDisplayCell...
        tableView.reloadData()
        fetchPostIds()
    }
    
    
    
    @objc func showSortContainer() {
        searchBar.resignFirstResponder()
        enableCancelButton(searchBar: searchBar)
        
        sortContainerViewBottomAnchor?.constant = 0
        dimView.isHidden = false
        navBarDimView.isHidden = false
        searchBar.alpha = 0.4

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func hideSortContainer() {
        sortContainerViewBottomAnchor?.constant = sortContainerHeight
        dimView.isHidden = true
        navBarDimView.isHidden = true
        searchBar.alpha = 1
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}






