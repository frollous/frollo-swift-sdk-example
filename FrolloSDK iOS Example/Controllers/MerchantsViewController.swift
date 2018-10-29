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

class MerchantsViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Merchant>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = DataManager.shared.frolloSDK.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Merchant.name), ascending: true)]
        fetchedResultsController = DataManager.shared.frolloSDK.aggregation.merchantsFetchedResultsController(context: context, sortedBy: sortDescriptors)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.frolloSDK.aggregation.refreshMerchants { (error) in
            if let refreshError = error {
                print(refreshError.localizedDescription)
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

}
