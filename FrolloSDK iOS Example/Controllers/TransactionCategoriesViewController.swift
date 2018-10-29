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

class TransactionCategoriesViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<TransactionCategory>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = DataManager.shared.frolloSDK.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(TransactionCategory.name), ascending: true)]
        fetchedResultsController = DataManager.shared.frolloSDK.aggregation.transactionCategoriesFetchedResultsController(context: context, sortedBy: sortDescriptors)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

}
