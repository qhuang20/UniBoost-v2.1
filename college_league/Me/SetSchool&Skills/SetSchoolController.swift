//
//  SetSchoolController.swift
//  college_league
//
//  Created by Qichen Huang on 2018-03-30.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import Firebase

class SetSchoolController: UITableViewController, UISearchBarDelegate {
    
    weak var editProfileController: EditProfileController?
    
    var schools = [String]()
    var filteredSchools = [String]()
   
    let cellId = "cellId"
    let searchController = UISearchController(searchResultsController: nil)
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar.getSearchBar()
        return sb
    }()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter Course Code"
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.getSchool() == nil {
            popUpErrorView(text: "Select Your School")
        }
    }
    
    override func viewDidLoad() {
        navigationItem.title = "School"
        navigationController?.navigationBar.tintColor = themeColor

        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(searchBar)
        searchBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 1, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        fetchShools()
    }
    
    deinit {
        print("deinit")
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
        let school = filteredSchools[indexPath.item]
        editProfileController?.schoolLabel.text = school
        searchController.isActive = false
        searchBarCancelButtonClicked(searchController.searchBar)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            filteredSchools = schools.filter { school in
                return school.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            filteredSchools = schools
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.searchBar.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        if UserDefaults.standard.getSchool() == nil {
            self.editProfileController?.handleSave()
        }
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





