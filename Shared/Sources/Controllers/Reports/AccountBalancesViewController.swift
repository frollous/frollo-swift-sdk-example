//
//  AccountBalancesViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 6/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class AccountBalancesViewController: UITableViewController {
    
    public var accountID: Int64 = -1
    
    private let currencyFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    private let now = Date()
    private let fromDate = Date().addingTimeInterval(-7800000) // 3+ months ago approx
    
    private var period: ReportAccountBalance.Period = .day
    private var reports: [ReportAccountBalance] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.reports.refreshAccountBalanceReports(period: period, from: fromDate, to: now, accountID: accountID) { (error) in
            if let refreshError = error {
                print(refreshError.localizedDescription)
            }
            
            self.reloadData()
        }
        
        reloadData()
    }
    
    // MARK: - Reports
    
    private func reloadData() {
        let context = FrolloSDK.shared.database.viewContext
        
        reports = FrolloSDK.shared.reports.accountBalanceReports(context: context, from: fromDate, to: now, period: period) ?? []
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell", for: indexPath)

        let report = reports[indexPath.row]
        
        cell.textLabel?.text = dateFormatter.string(from: report.date)
        cell.detailTextLabel?.text = currencyFormatter.string(for: report.value)

        return cell
    }

}
