//
//  SuggestedTagsViewController.swift
//  FrolloSDK Example
//
//  Created by Maher Santina on 9/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK
import CoreData

class SuggestedTagsViewController: TableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    public var searchEnabled = true
    
    private var searchResultsController: UISearchController!
    private var searchTerm: String? = nil {
        didSet {
            updateData()
        }
    }
    
    private var data: [SuggestedTag] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        if searchEnabled {
            let controller = defaultSearchController(placeHolder: "Search Tags")
            searchResultsController = controller
        }
        updateData()
    }
    
    private func updateData() {
        spinner.startAnimating()
        FrolloSDK.shared.aggregation.transactionSuggestedTags(searchTerm: searchTerm ?? "") { (result) in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                switch result {
                case .success(let data):
                    self.data = data
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SuggestedTagCell
        
        let tag = data[indexPath.row]
        cell.nameLabel.text = tag.name
        
        return cell
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchTerm = nil
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchTerm = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = searchBar.text
        guard let searchTerm = searchBar.text,
            !searchTerm.isEmpty
            else {
                searchBar.resignFirstResponder()
                return
        }
    }
    
    // MARK: - Search Results
    
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else {
            return
        }
        searchTerm = searchController.searchBar.text
    }
    
}
