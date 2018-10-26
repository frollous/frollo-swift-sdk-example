//
//  TableViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 26/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

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

}
