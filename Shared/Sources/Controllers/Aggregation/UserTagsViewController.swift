//
//  UserTagsViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 8/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK
import CoreData

class UserTagsViewController: TableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet var spinner: UIActivityIndicatorView!

    public var searchEnabled = true
    
    private var fetchedResultsController: NSFetchedResultsController<Tag>!
    private var searchResultsController: UISearchController!
    private var searchTerm: String? = nil {
        didSet {
            updateData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        initializeFetchedResultsController()
        
        if searchEnabled {
            let controller = defaultSearchController(placeHolder: "Search Tags")
            searchResultsController = controller
        }
        spinner.startAnimating()
        Frollo.shared.aggregation.refreshTransactionUserTags { (_) in
            self.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    private func initializeFetchedResultsController() {
        let context = Frollo.shared.database.viewContext
        
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
        fetchedResultsController = Frollo.shared.aggregation.transactionUserTagsFetchedResultsController(context: context, filteredBy: nil, sortedBy: sortDescriptors)
    }
    
    private func reloadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    private func updateData() {
        var predicate: NSPredicate?
        if let term = searchTerm, !term.isEmpty {
            predicate = NSPredicate(format: "name CONTAINS[cd] %@", argumentArray: [term])
        }
        fetchedResultsController.fetchRequest.predicate = predicate
        reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTagCell
        
        let tag = fetchedResultsController.object(at: indexPath)
        cell.data = tag
        
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
