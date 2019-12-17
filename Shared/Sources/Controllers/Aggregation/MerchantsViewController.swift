//
//  MerchantsViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 29/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

protocol MerchantDelegate: AnyObject {
    func merchantDidselect(merchant: Merchant)
}

class MerchantsViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Merchant>!
    @IBOutlet var searchBar: UISearchBar!
    weak var delegate: MerchantDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = Frollo.shared.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.name), ascending: true)]
        fetchedResultsController = Frollo.shared.aggregation.merchantsFetchedResultsController(context: context, sortedBy: sortDescriptors)
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.aggregation.refreshCachedMerchants(){ (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }
    
    // MARK: - Merchants
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCell", for: indexPath)
        
        let merchant = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = merchant.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let delegate = delegate else {
            return
        }
        
        let merchant = fetchedResultsController.object(at: indexPath)
        delegate.merchantDidselect(merchant: merchant)
        navigationController?.popViewController(animated: true)
    }

}

extension MerchantsViewController : UISearchBarDelegate {
    
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
