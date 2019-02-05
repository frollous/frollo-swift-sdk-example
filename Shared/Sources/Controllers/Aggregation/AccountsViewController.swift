//
//  AccountsViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 26/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class AccountsViewController: TableViewController {
    
    public var providerAccountID: Int64 = -1
    
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
    
    private var fetchedResultsController: NSFetchedResultsController<Account>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = FrolloSDK.shared.database.viewContext
        let predicate = NSPredicate(format: "providerAccountID == %ld", argumentArray: [providerAccountID])
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Account.accountTypeRawValue), ascending: true), NSSortDescriptor(key: #keyPath(Account.accountName), ascending: true)]
        fetchedResultsController = FrolloSDK.shared.aggregation.accountsFetchedResultsController(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.aggregation.refreshAccounts { (error) in
            if let refreshError = error {
                print(refreshError.localizedDescription)
            }
        }
        
        reloadData()
    }
    
    // MARK: - Interaction
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "TransactionSegue",
            let transactionsViewController = segue.destination as? TransactionsViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let account = fetchedResultsController.object(at: indexPath)
            transactionsViewController.accountID = account.accountID
        }
    }
    
    // MARK: - Accounts
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell

        let account = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = account.nickName ?? account.accountName
        
        // Reset cell
        cell.spinner.stopAnimating()
        cell.balanceLabel.isHidden = false
        
        switch account.refreshStatus {
            case .adding:
                cell.spinner.startAnimating()
                cell.balanceLabel.isHidden = true
                cell.statusLabel.text = "Adding"
            case .failed:
                cell.statusLabel.text = "Failed"
            case .needsAction:
                cell.statusLabel.text = "Needs Action"
            case .success:
                cell.statusLabel.text = "Success"
            case .updating:
                cell.spinner.startAnimating()
                cell.balanceLabel.isHidden = true
                cell.statusLabel.text = "Updating"
        }
        
        if let lastRefreshDate = account.lastRefreshed {
            cell.updatedLabel.text = "Last updated " + dateFormatter.string(from: lastRefreshDate)
        } else {
            cell.updatedLabel.text = "Never Updated"
        }
        
        if let balance = account.availableBalance as Decimal? {
            cell.balanceLabel.text = currencyFormatter.string(for: balance)
        } else if let balance = account.currentBalance as Decimal? {
            cell.balanceLabel.text = currencyFormatter.string(for: balance)
        } else {
            cell.balanceLabel.isHidden = true
        }

        return cell
    }

}
