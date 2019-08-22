//
//  BillsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 10/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class BillsViewController: TableViewController {
    
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
    
    private var fetchedResultsController: NSFetchedResultsController<Bill>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "BillCell", bundle: nil), forCellReuseIdentifier: "BillCell")

        let context = Frollo.shared.database.viewContext
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(Bill.statusRawValue), ascending: false), NSSortDescriptor(key: #keyPath(Bill.name), ascending: true)]
        fetchedResultsController = Frollo.shared.bills.billsFetchedResultsController(context: context, sortedBy: sortDescriptors)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.bills.refreshBills { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }
    
    // MARK: - Bills
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as! BillCell
        
        let bill = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = bill.name
        cell.dateLabel.text = "Next due: " + dateFormatter.string(from: bill.nextPaymentDate)
        cell.detailsLabel.text = bill.transactionCategory?.name
        cell.amountLabel.text  = currencyFormatter.string(from: bill.dueAmount)
        
        switch bill.frequency {
            case .annually:
                cell.statusLabel.text = "Annually"
            case .biannually:
                cell.statusLabel.text = "Biannually"
            case .fortnightly:
                cell.statusLabel.text = "Fortnightly"
            case .fourWeekly:
                cell.statusLabel.text = "Every four weeks"
            case .irregular:
                cell.statusLabel.text = "Irregular"
            case .monthly:
                cell.statusLabel.text = "Monthly"
            case .quarterly:
                cell.statusLabel.text = "Quarterly"
            case .unknown:
                cell.statusLabel.text = "Unknown"
            case .weekly:
                cell.statusLabel.text = "Weekly"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bill = fetchedResultsController.object(at: indexPath)
        
        let billPaymentsViewController = storyboard?.instantiateViewController(withIdentifier: "BillPaymentsViewController") as! BillPaymentsViewController
        billPaymentsViewController.billID = bill.billID
        navigationController?.pushViewController(billPaymentsViewController, animated: true)
    }

}
