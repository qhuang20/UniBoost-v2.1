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
    
    weak var editProfileController: EditProfileController?
    
    var schools = [String]()
    var filteredSchools = [String]()
   
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
        tableView.tableHeaderView = searchController.searchBar///tableHeaderView
        definesPresentationContext = true
        
        fetchShools()
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchController.isActive = true
        searchController.searchBar.setShowsCancelButton(true, animated: true)
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSchools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let school = filteredSchools[indexPath.row]
        cell.textLabel!.text = school
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editProfileController?.schoolLabel.text = filteredSchools[indexPath.item]
        searchController.isActive = false
        searchBarCancelButtonClicked(searchController.searchBar)
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredSchools = schools.filter { school in
                return school.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            filteredSchools = schools
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { (_) in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    
    private func fetchShools() {
        let ref = Database.database().reference().child("schools")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            var counter = 0
            
            allObjects.forEach({ (snapshot) in
                let school = snapshot.key
                self.schools.append(school)
                
                counter = counter + 1
                if allObjects.count == counter {
                    self.filteredSchools = self.schools
                    self.tableView.reloadData()
                }
            })
        }
    }
    
}





