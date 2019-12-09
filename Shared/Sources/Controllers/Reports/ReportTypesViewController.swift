//
//  ReportTypesViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 6/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class ReportTypesViewController: UITableViewController {
    
    enum ReportType: CaseIterable {
        case accountBalance
        case transactionCurrent
        case transactionHistory
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ReportType.allCases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)

        switch ReportType.allCases[indexPath.row] {
            case .accountBalance:
                cell.textLabel?.text = "Account Balances"
            case .transactionCurrent:
                cell.textLabel?.text = "Current Transaction Reports"
            case .transactionHistory:
                cell.textLabel?.text = "Historic Transaction Reports"

        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ReportType.allCases[indexPath.row] {
            case .accountBalance:
                let viewController = storyboard?.instantiateViewController(withIdentifier: "ReportsAccountListViewController") as! ReportsAccountListViewController
                navigationController?.pushViewController(viewController, animated: true)
            case .transactionCurrent:
                let viewController = storyboard?.instantiateViewController(withIdentifier: "ReportTypeTransactionViewController") as! ReportTypeTransactionViewController
                viewController.current = true
                navigationController?.pushViewController(viewController, animated: true)
            case .transactionHistory:
                let viewController = storyboard?.instantiateViewController(withIdentifier: "ReportTypeTransactionViewController") as! ReportTypeTransactionViewController
                viewController.current = false
                navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
