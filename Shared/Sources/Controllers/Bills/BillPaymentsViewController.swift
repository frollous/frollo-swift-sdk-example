//
//  BillPaymentsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 10/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class BillPaymentsViewController: TableViewController {
    
    internal var billID: Int64!
    
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
    
    private var fetchedResultsController: NSFetchedResultsController<BillPayment>!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "BillCell", bundle: nil), forCellReuseIdentifier: "BillCell")
        
        let context = Frollo.shared.database.viewContext
        let predicate = NSPredicate(format: #keyPath(BillPayment.billID) + " == %ld", argumentArray: [billID!])
        let sortDescriptors = [NSSortDescriptor(key: #keyPath(BillPayment.dateString), ascending: false)]
        fetchedResultsController = Frollo.shared.bills.billPaymentsFetchedResultsController(context: context, filteredBy: predicate, sortedBy: sortDescriptors)
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshBillPayments()
        
        reloadData()
    }
    
    // MARK: - Bill Payments
    
    private func refreshBillPayments() {
        let calendar = Calendar.current
        
        let yearAgoComponents = DateComponents(year: -1)
        let yearComponents = DateComponents(year: 1)
        
        var fromDate = calendar.date(byAdding: yearAgoComponents, to: Date())!
        fromDate = calendar.date(bySetting: .day, value: 1, of: fromDate)!
        fromDate = calendar.startOfDay(for: fromDate)
        
        var toDate = calendar.date(byAdding: yearComponents, to: Date())!
        toDate = calendar.date(bySetting: .day, value: 1, of: toDate)!
        toDate = calendar.startOfDay(for: toDate)
        
        Frollo.shared.bills.refreshBillPayments(from: fromDate, to: toDate) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
    }
    
    private func reloadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    private func markBillPaymentPaid(billPaymentID: Int64) {
        let context = Frollo.shared.database.newBackgroundContext()
        
        context.performAndWait {
            let billPayment = Frollo.shared.bills.billPayment(context: context, billPaymentID: billPaymentID)
            
            billPayment?.paymentStatus = .paid
            
            try? context.save()
        }
        
        Frollo.shared.bills.updateBillPayment(billPaymentID: billPaymentID)
    }
    
    private func removeBill(billPaymentID: Int64) {
        Frollo.shared.bills.deleteBillPayment(billPaymentID: billPaymentID)
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
        
        let billPayment = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = billPayment.name
        cell.dateLabel.text = dateFormatter.string(from: billPayment.date)
        cell.detailsLabel.text = billPayment.bill?.account?.accountName
        cell.amountLabel.text = currencyFormatter.string(from: billPayment.amount!)
        
        switch billPayment.paymentStatus {
            case .due:
                cell.statusLabel.text = "Due"
            case .future:
                cell.statusLabel.text = "Future"
            case .overdue:
                cell.statusLabel.text = "Overdue"
            case .paid:
                cell.statusLabel.text = "Paid"
        }
        
        cell.accessoryType = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let billPayment = fetchedResultsController.object(at: indexPath)
        
        let removeAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let billPayment = self.fetchedResultsController.object(at: indexPath)
            
            self.removeBill(billPaymentID: billPayment.billPaymentID)
        }
        removeAction.backgroundColor = UIColor.red
        
        if billPayment.paymentStatus == .paid {
            return [removeAction]
        }
        
        let paidAction = UITableViewRowAction(style: .normal, title: "Paid") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let billPayment = self.fetchedResultsController.object(at: indexPath)
            
            self.markBillPaymentPaid(billPaymentID: billPayment.billPaymentID)
        }
        paidAction.backgroundColor = UIColor.green
        
        return [paidAction, removeAction]
    }

}
