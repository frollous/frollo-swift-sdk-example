//
//  TransactionsReportTableViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 17/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class TransactionsReportTableViewController: UITableViewController {
    
    var data: [ReportItemDisplayable] = [] {
        didSet {
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ReportItemTableViewCell
        cell.data = data[indexPath.row]
        return cell
    }

}
