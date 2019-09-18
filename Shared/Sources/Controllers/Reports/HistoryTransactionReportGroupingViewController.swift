//
//  HistoryTransactionReportGroupingViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 7/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class HistoryTransactionReportGroupingViewController: UITableViewController {
    
    public var grouping: ReportGrouping = .budgetCategory
    
    private let fromDate = Date(timeIntervalSinceNow: -31622400) // Roughly a year ago
    private let now = Date()
    
    private var budgetCategories: [BudgetCategory] = []
    private var merchants: [Merchant] = []
    private var transactionCategories: [TransactionCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.reports.refreshTransactionHistoryReports(grouping: grouping, period: .month, from: fromDate, to: now) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    self.reloadData()
            }
        }
        
        reloadData()
    }
    
    // MARK: - Reports
    
    private func reloadData() {
        let context = Frollo.shared.database.viewContext
        
        let reports = Frollo.shared.reports.historyTransactionReports(context: context, from: fromDate, to: now, grouping: grouping, period: .month) ?? []
        
        switch grouping {
            case .budgetCategory:
                let allBudgetCategories = reports.compactMap { $0.budgetCategory }
                let uniqueCategories = Set(allBudgetCategories)
                budgetCategories = uniqueCategories.sorted(by: { (categoryA, categoryB) -> Bool in
                    return categoryA.rawValue.compare(categoryB.rawValue) == .orderedAscending
                })
            case .merchant:
                let allMerchants = reports.compactMap { $0.merchant }
                let uniqueMerchants = Set(allMerchants)
                merchants = uniqueMerchants.sorted(by: { (merchantA, merchantB) -> Bool in
                    return merchantA.name.compare(merchantB.name) == .orderedAscending
                })
            case .transactionCategory:
                let allTransactionCategories = reports.compactMap { $0.transactionCategory }
                let uniqueTransactionCategories = Set(allTransactionCategories)
                transactionCategories = uniqueTransactionCategories.sorted(by: { (categoryA, categoryB) -> Bool in
                    return categoryA.name.compare(categoryB.name) == .orderedAscending
                })
            case .transactionCategoryGroup:
                break
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch grouping {
            case .budgetCategory:
                return budgetCategories.count
            case .merchant:
                return merchants.count
            case .transactionCategory:
                return transactionCategories.count
            case .transactionCategoryGroup:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        
        switch grouping {
            case .budgetCategory:
                let budgetCategory = budgetCategories[indexPath.row]
                cell.textLabel?.text = budgetCategory.rawValue.capitalized
            case .merchant:
                let merchant = merchants[indexPath.row]
                cell.textLabel?.text = merchant.name
            case .transactionCategory:
                let category = transactionCategories[indexPath.row]
                cell.textLabel?.text = category.name
            case .transactionCategoryGroup:
                break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "HistoryTransactionReportsViewController") as! HistoryTransactionReportsViewController
        viewController.grouping = grouping
        viewController.fromDate = fromDate
        viewController.toDate = now

        switch grouping {
            case .budgetCategory:
                let budgetCategory = budgetCategories[indexPath.row]
                viewController.budgetCategory = budgetCategory
            case .merchant:
                let merchant = merchants[indexPath.row]
                viewController.linkedID = merchant.merchantID
            case .transactionCategory:
                let category = transactionCategories[indexPath.row]
                viewController.linkedID = category.transactionCategoryID
            default:
                break
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

}
