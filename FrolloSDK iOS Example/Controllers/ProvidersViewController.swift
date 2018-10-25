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

class ProvidersViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var fetchedResultsController: NSFetchedResultsController<Provider>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = DataManager.shared.frolloSDK.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Provider.popular), ascending: false)]
        fetchedResultsController = DataManager.shared.frolloSDK.aggregation.providersFetchedResultsController(context: context, sortedBy: sortDescriptors)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.frolloSDK.aggregation.refreshProviders { (error) in
            DispatchQueue.main.async {
                if let refreshError = error {
                    print(refreshError.localizedDescription)
                }
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
    
    // MARK: - Fetched Results Controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
            default:
                return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .none)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .none)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .none)
                tableView.insertRows(at: [newIndexPath!], with: .none)
            case .update:
                if let insertIndexPath = newIndexPath {
                    tableView.deleteRows(at: [indexPath!], with: .none)         // Treating as a move fixes issues with moving cells between sections
                    tableView.insertRows(at: [insertIndexPath], with: .none)
                } else {
                    tableView.reloadRows(at: [indexPath!], with: .none)
                }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
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
