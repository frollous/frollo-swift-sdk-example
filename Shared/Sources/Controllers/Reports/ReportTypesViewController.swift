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
        case transaction
        case survey
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
            case .transaction:
                cell.textLabel?.text = "Transaction Reports"
            case .survey:
                cell.textLabel?.text = "Start a survey"
        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ReportType.allCases[indexPath.row] {
            case .accountBalance:
                let viewController = storyboard?.instantiateViewController(withIdentifier: "ReportsAccountListViewController") as! ReportsAccountListViewController
                navigationController?.pushViewController(viewController, animated: true)
            case .transaction:
                let viewController = storyboard?.instantiateViewController(withIdentifier: "TransactionReportFormViewController") as! TransactionReportFormViewController
                let viewModel = TransactionReportFormViewModel()
                viewController.dataSource = viewModel
                viewController.delegate = viewModel
                viewController.current = true
                navigationController?.pushViewController(viewController, animated: true)
        case .survey:
                let storyboard = UIStoryboard(name: "Surveys", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SurveyViewController")  as! SurveyViewController
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
