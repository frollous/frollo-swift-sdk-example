//
//  ProviderAccountsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 18/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class ProviderAccountsViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<ProviderAccount>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = FrolloSDK.shared.database.viewContext
        fetchedResultsController = FrolloSDK.shared.aggregation.providerAccountsFetchedResultsController(context: context)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }

    // MARK: - Interaction
    
    @available(tvOS, unavailable)
    @IBAction func refreshTriggered(sender: UIRefreshControl) {
        FrolloSDK.shared.aggregation.refreshProviderAccounts { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
                
            sender.endRefreshing()
        }
    }
    
    @IBAction func logoutPress(sender: UIBarButtonItem) {
        FrolloSDK.shared.authentication.logoutUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AccountSegue",
            let accountsViewController = segue.destination as? AccountsViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let providerAccount = fetchedResultsController.object(at: indexPath)
            accountsViewController.providerAccountID = providerAccount.providerAccountID
        } else if segue.identifier == "SearchSegue",
            let navigationController = segue.destination as? UINavigationController,
            let transactionsViewController = navigationController.viewControllers.first as? TransactionsViewController {
            transactionsViewController.searchEnabled = true
        }
    }
    
    // MARK: - Fetch Provider Accounts
    
    private func reloadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! ProviderAccountCell
        
        let providerAccount = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = providerAccount.provider?.name ?? "Unknown Provider Account"
        
        if let accountCount = providerAccount.accounts?.count {
            cell.accountsLabel.isHidden = false
            cell.accountsLabel.text = String(format: "%ld Accounts", arguments: [accountCount])
        } else {
            cell.accountsLabel.isHidden = true
        }
        
        return cell
    }
    
}
