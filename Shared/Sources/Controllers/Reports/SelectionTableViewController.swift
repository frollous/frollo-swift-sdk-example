//
//  SelectionTableViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 17/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

protocol SelectionDisplayable {
    var title: String? { get }
}

protocol SelectionTableViewControllerDataSource {
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, itemsForType: SelectionTableViewController.SelectionType) -> [SelectionDisplayable]
}

class SelectionTableViewController: UITableViewController {
    
    enum SelectionType {
        case filter
        case filterBy
        case grouping
        case period
    }
    
    var dataSource: SelectionTableViewControllerDataSource? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var type: SelectionType?
    
    var items: [SelectionDisplayable] {
        guard let type = type else { return [] }
        return dataSource?.selectionTableViewController(self, itemsForType: type) ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }

}
