//
//  TransactionsViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 26/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class TransactionsViewController: TableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    public var accountID: Int64?
    public var searchEnabled = false
    
    private let currencyFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private var fetchedResultsController: NSFetchedResultsController<Transaction>!
    private var searchResultsController: UISearchController!
    private var transactionSearchIDs = [Int64]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        let context = Frollo.shared.database.viewContext
        var predicate: NSPredicate?
        if let id = accountID {
            predicate = NSPredicate(format: #keyPath(Transaction.accountID) + " == %ld", argumentArray: [id])
        }
        
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.transactionDateString), ascending: false)]
        fetchedResultsController = Frollo.shared.aggregation.transactionsFetchedResultsController(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
        
        if searchEnabled {
            let controller = defaultSearchController(placeHolder: "Search Transactions")
            searchResultsController = controller
        }
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.aggregation.refreshTransactions(transactionFilter: TransactionFilter(size: 300), completion: nil)
        
        reloadData()
    }
    
    // MARK: - Interaction
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "DetailSegue",
            let detailsViewController = segue.destination as? TransactionDetailsViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let transaction = fetchedResultsController.object(at: indexPath)
            detailsViewController.transactionID = transaction.transactionID
        }
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    // MARK: - Transactions
    
    private func reloadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections
            else {
                return 0
        }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections
            else {
                return 0
        }
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell

        let transaction = fetchedResultsController.object(at: indexPath)
        
        if let customName = transaction.userDescription {
            cell.nameLabel.text = customName
        } else if let simpleName = transaction.simpleDescription {
            cell.nameLabel.text = simpleName
        } else {
            cell.nameLabel.text = transaction.originalDescription
        }
        
        if let amount = transaction.amount as Decimal? {
            cell.amountLabel.isHidden = false
            cell.amountLabel.text = currencyFormatter.string(for: amount)
        } else {
            cell.amountLabel.isHidden = true
        }
        
        cell.dateLabel.text = dateFormatter.string(from: transaction.transactionDate)
        cell.tagsCollectionView.data = transaction.userTags

        return cell
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        transactionSearchIDs = []
        
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        transactionSearchIDs = []
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text,
            !searchTerm.isEmpty
            else {
                searchBar.resignFirstResponder()
                return
        }
        
        spinner.startAnimating()
        
        Frollo.shared.aggregation.transactionSearch(searchTerm: searchTerm) { (result) in
            self.spinner.stopAnimating()
            
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let transactionIDs):
                    self.transactionSearchIDs = transactionIDs
                    
                    self.updateSearchResults(for: self.searchResultsController)
            }
        }
    }
    
    // MARK: - Search Results
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: #keyPath(Transaction.transactionID) + " IN %@", argumentArray: [transactionSearchIDs])
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        
        try? fetchedResultsController.performFetch()
        
        tableView.reloadData()
    }

}
