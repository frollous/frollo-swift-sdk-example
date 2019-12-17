//
//  TransactionCategoriesViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 29/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

protocol TransactionCategoryDelegate: AnyObject {
    func transactionCatrgoryDidSelect(transactionCategory: TransactionCategory)
}

class TransactionCategoriesViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<TransactionCategory>!
    
    @IBOutlet var searchBar: UISearchBar!
    weak var delegate: TransactionCategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = Frollo.shared.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(TransactionCategory.name), ascending: true)]
        fetchedResultsController = Frollo.shared.aggregation.transactionCategoriesFetchedResultsController(context: context, sortedBy: sortDescriptors)
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.aggregation.refreshTransactionCategories { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success:
                break
            }
        }
        
        reloadData()
    }
    
    // MARK: - Transaction Categories
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let category = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = category.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegate = delegate else {
            return
        }
        
        let transactionCategory = fetchedResultsController.object(at: indexPath)
        delegate.transactionCatrgoryDidSelect(transactionCategory: transactionCategory)
        navigationController?.popViewController(animated: true)
    }

}


extension TransactionCategoriesViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateFilter(searchTerm: searchText)
    }
    
    func updateFilter(searchTerm: String) {
        
        if searchTerm.isEmpty {
             fetchedResultsController.fetchRequest.predicate = nil
        } else {
            let predicates = [NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)]
            
            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            
        }
        
        tableView.reloadData()
    }
}
