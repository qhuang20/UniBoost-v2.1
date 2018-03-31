//
//  SetSchoolController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-30.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SetSchoolController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    let schools = ["lang", "usb", "ccc"]
   
    let cellId = "cellId"
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        navigationItem.title = "School"
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = themeColor
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search School"
        searchController.searchBar.barTintColor = themeColor
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let school = schools[indexPath.row]
        cell.textLabel!.text = school
        return cell
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
//        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
//            filteredNFLTeams = unfilteredNFLTeams.filter { team in
//                return team.lowercased().contains(searchText.lowercased())
//            }
//            
//        } else {
//            filteredNFLTeams = unfilteredNFLTeams
//        }
//        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
}





