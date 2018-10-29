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

class TransactionsViewController: TableViewController {
    
    public var accountID: Int64 = -1
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = DataManager.shared.frolloSDK.database.viewContext
        let predicate = NSPredicate(format: #keyPath(Transaction.accountID) + " == %ld", argumentArray: [accountID])
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Transaction.transactionDateString), ascending: false)]
        fetchedResultsController = DataManager.shared.frolloSDK.aggregation.transactionsFetchedResultsController(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fromDate = Date().addingTimeInterval(-7776000) //  3 months ago
        DataManager.shared.frolloSDK.aggregation.refreshTransactions(from: fromDate, to: Date())
        
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
        } else if let originalName = transaction.originalDescription {
            cell.nameLabel.text = originalName
        } else {
            cell.nameLabel.text = "Unnamed Transaction"
        }
        
        if let amount = transaction.amount as Decimal? {
            cell.amountLabel.isHidden = false
            cell.amountLabel.text = currencyFormatter.string(for: amount)
        } else {
            cell.amountLabel.isHidden = true
        }
        
        cell.dateLabel.text = dateFormatter.string(from: transaction.transactionDate)

        return cell
    }

}
