//
//  ReportTypeTransactionViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 6/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

class ReportTypeTransactionViewController: UITableViewController {
    
    public var current = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ReportGrouping.allCases.count - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)

        switch ReportGrouping.allCases[indexPath.row] {
            case .budgetCategory:
                cell.textLabel?.text = "Budget Category"
            case .merchant:
                cell.textLabel?.text = "Merchant"
            case .transactionCategory:
                cell.textLabel?.text = "Transaction Category"
            default:
                break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grouping = ReportGrouping.allCases[indexPath.row]
        
        if current {
            let currentTransactionReportViewController = storyboard?.instantiateViewController(withIdentifier: "CurrentTransactionsReportGroupingViewController") as! CurrentTransactionsReportGroupingViewController
            currentTransactionReportViewController.grouping = grouping
            navigationController?.pushViewController(currentTransactionReportViewController, animated: true)
        } else {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "HistoryTransactionReportGroupingViewController") as! HistoryTransactionReportGroupingViewController
            viewController.grouping = grouping
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
