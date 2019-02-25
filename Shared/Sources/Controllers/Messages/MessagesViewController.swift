//
//  MessagesViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 21/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class MessagesViewController: TableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Message>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = FrolloSDK.shared.database.viewContext
        let predicate = NSPredicate(format: #keyPath(Message.read) + " == false && " + #keyPath(Message.contentTypeRawValue) + " == %@", argumentArray: [Message.ContentType.text.rawValue])
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.placement), ascending: false)]
        fetchedResultsController = FrolloSDK.shared.messages.messagesFetchedResultsController(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.messages.refreshUnreadMessages() { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }
    
    // MARK: - Messages
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell

        if let message = fetchedResultsController.object(at: indexPath) as? MessageText {
            cell.titleLabel.text = message.title
            cell.headerLabel.text = message.header
            cell.bodyLabel.text = message.text
            cell.footerLabel.text = message.footer
            cell.actionLabel.text = message.actionTitle
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = fetchedResultsController.object(at: indexPath)
        
        guard let actionLink = message.actionURLString,
            let url = URL(string: actionLink)
            else {
                return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
