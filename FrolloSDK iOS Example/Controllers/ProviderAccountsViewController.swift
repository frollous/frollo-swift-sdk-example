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

class ProviderAccountsViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<ProviderAccount>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = DataManager.shared.frolloSDK.database.viewContext
        fetchedResultsController = DataManager.shared.frolloSDK.aggregation.providerAccountsFetchedResultsController(context: context)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.frolloSDK.aggregation.refreshProviderAccounts { (error) in
            DispatchQueue.main.async {
                if let refreshError = error {
                    print(refreshError.localizedDescription)
                } else {
                    self.reloadData()
                }
            }
        }
        
        //reloadData()
    }

    // MARK: - Interaction
    
    @IBAction func refreshTriggered(sender: UIRefreshControl) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
        
        let providerAccount = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = providerAccount.provider?.name ?? "Unknown Provider Account"
        
        if let accountCount = providerAccount.accounts?.count {
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = String(format: "%ld Accounts", arguments: [accountCount])
        } else {
            cell.detailTextLabel?.isHidden = true
        }
        
        return cell
    }
    
}
