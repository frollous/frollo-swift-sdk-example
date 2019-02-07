//
//  ReportsAccountListViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 6/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class ReportsAccountListViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Account>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = FrolloSDK.shared.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Account.providerAccountID), ascending: true), NSSortDescriptor(key: #keyPath(Account.accountTypeRawValue), ascending: true), NSSortDescriptor(key: #keyPath(Account.accountName), ascending: true)]
        fetchedResultsController = FrolloSDK.shared.aggregation.accountsFetchedResultsController(context: context, filteredBy: nil, sortedBy: sortDescriptors)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        let account = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = account.providerAccount?.provider?.name ?? account.providerName
        cell.detailTextLabel?.text = account.nickName ?? account.accountName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = fetchedResultsController.object(at: indexPath)
        
        let accountBalanceViewController = storyboard?.instantiateViewController(withIdentifier: "AccountBalancesViewController") as! AccountBalancesViewController
        accountBalanceViewController.accountID = account.accountID
        navigationController?.pushViewController(accountBalanceViewController, animated: true)
    }

}
