//
//  ProvidersViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 25/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class ProvidersViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Provider>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = Frollo.shared.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Provider.popular), ascending: false), NSSortDescriptor(key: #keyPath(Provider.name), ascending: true)]
        fetchedResultsController = Frollo.shared.aggregation.providersFetchedResultsController(context: context, sortedBy: sortDescriptors)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.aggregation.refreshProviders { (result) in
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
    
    @IBAction func cancelPress(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AddAccountSegue",
            let addAccountViewController = segue.destination as? AddProviderAccountViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let provider = fetchedResultsController.object(at: indexPath)
            addAccountViewController.providerID = provider.providerID
        }
    }
    
    // MARK: - Providers
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath)

        let provider = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = provider.name

        return cell
    }

}
