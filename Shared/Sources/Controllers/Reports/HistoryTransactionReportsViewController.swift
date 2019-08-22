//
//  HistoryTransactionReportsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 7/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class HistoryTransactionReportsViewController: UITableViewController {
    
    public var fromDate: Date = Date()
    public var toDate: Date = Date()
    public var budgetCategory: BudgetCategory?
    public var grouping: ReportGrouping = .budgetCategory
    public var linkedID: Int64?
    
    private let currencyFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private var reports: [ReportTransactionHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.reports.refreshTransactionCurrentReports(grouping: grouping) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
            
            self.reloadData()
        }
        
        reloadData()
    }
    
    // MARK: - Reports
    
    private func reloadData() {
        let context = Frollo.shared.database.viewContext
        
        var predicates = [NSPredicate(format: #keyPath(ReportTransactionHistory.groupingRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.periodRawValue) + " == %@ && " + #keyPath(ReportTransactionHistory.filterBudgetCategoryRawValue) + " == nil", argumentArray: [grouping.rawValue, ReportTransactionHistory.Period.month.rawValue])]
        
        let fromDateString = ReportTransactionHistory.monthlyDateFormatter.string(from: fromDate)
        let toDateString = ReportTransactionHistory.monthlyDateFormatter.string(from: toDate)
        predicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.dateString) + " >= %@ && " + #keyPath(ReportTransactionHistory.dateString) + " <= %@", argumentArray: [fromDateString, toDateString]))
        
        switch grouping {
            case .budgetCategory:
                if let category = budgetCategory {
                    predicates.append(NSPredicate(format: #keyPath(ReportTransactionHistory.budgetCategoryRawValue) + " == %@", argumentArray: [category.rawValue]))
                }
            case .merchant, .transactionCategory:
                if let id = linkedID {
                    predicates.append(NSPredicate(format: #keyPath(ReportTransactionCurrent.linkedID) + " == %ld", argumentArray: [id]))
                }
            case .transactionCategoryGroup:
                break
        }
        
        reports = Frollo.shared.reports.historyTransactionReports(context: context, filteredBy: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), sortedBy: [NSSortDescriptor(key: #keyPath(ReportTransactionHistory.dateString), ascending: false)]) ?? []
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath)
        
        let report = reports[indexPath.row]
        
        cell.textLabel?.text = dateFormatter.string(from: report.date)
        
        if let amount = report.value {
            cell.detailTextLabel?.text = currencyFormatter.string(from: amount)
        } else {
            cell.detailTextLabel?.text = currencyFormatter.string(for: 0)
        }
        
        return cell
    }

}
