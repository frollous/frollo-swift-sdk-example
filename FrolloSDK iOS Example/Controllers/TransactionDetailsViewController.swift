//
//  TransactionDetailsViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 26/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class TransactionDetailsViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var budgetCategoryButton: UIButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var merchantButton: UIButton!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var excludedSwitch: UISwitch!
    @IBOutlet var containerView: UIView!
    
    public var transactionID: Int64 = -1
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    private var fetchedTransaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - Transaction
    
    private func fetchTransaction() {
        let context = FrolloSDK.shared.database.viewContext
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "transactionID == %ld", argumentArray: [transactionID])
        
        do {
            fetchedTransaction = try context.fetch(fetchRequest).first
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func reloadData() {
        fetchTransaction()
        
        guard let transaction = fetchedTransaction
            else {
                return
        }
        
        nameLabel.text = transaction.simpleDescription
        detailsLabel.text = transaction.originalDescription
        dateLabel.text = dateFormatter.string(from: transaction.transactionDate)
        merchantButton.setTitle(transaction.merchant?.name ?? "Unknown Merchant", for: .normal)
        categoryButton.setTitle(transaction.transactionCategory?.name ?? "Unknown Category", for: .normal)
        
        switch transaction.budgetCategory {
            case .income:
                budgetCategoryButton.setTitle("Income", for: .normal)
            case .lifestyle:
                budgetCategoryButton.setTitle("Lifestyle", for: .normal)
            case .living:
                budgetCategoryButton.setTitle("Living", for: .normal)
            case .oneOff:
                budgetCategoryButton.setTitle("One Off", for: .normal)
            case .savings:
                budgetCategoryButton.setTitle("Savings", for: .normal)
        }
        
        if let currency = transaction.currency, let amount = transaction.amount as Decimal? {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.locale = Locale.autoupdatingCurrent
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = currency
            
            amountLabel.isHidden = false
            amountLabel.text = currencyFormatter.string(for: amount)
        } else {
            amountLabel.isHidden = true
        }
        
        excludedSwitch.isOn = !transaction.included
    }
    
    // MARK: - Interaction
    
    @IBAction func budgetCategoryPress(sender: UIButton) {
        let alertController = UIAlertController(title: "Budget Category", message: nil, preferredStyle: .actionSheet)
        
        let incomeAction = UIAlertAction(title: "Income", style: .default) { (action) in
            self.fetchedTransaction?.budgetCategory = .income
        }
        alertController.addAction(incomeAction)
        
        let lifestyleAction = UIAlertAction(title: "Lifestyle", style: .default) { (action) in
            self.fetchedTransaction?.budgetCategory = .lifestyle
        }
        alertController.addAction(lifestyleAction)
        
        let livingAction = UIAlertAction(title: "Living", style: .default) { (action) in
            self.fetchedTransaction?.budgetCategory = .living
        }
        alertController.addAction(livingAction)
        
        let savingsAction = UIAlertAction(title: "Savings", style: .default) { (action) in
            self.fetchedTransaction?.budgetCategory = .savings
        }
        alertController.addAction(savingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func excludedSwitched(sender: UISwitch) {
        fetchedTransaction?.included = !sender.isOn
    }
    
    @IBAction func savePress(sender: UIBarButtonItem) {
        guard let transaction = fetchedTransaction
        else {
            return
        }
        
        containerView.isHidden = true
        spinner.startAnimating()
        
        FrolloSDK.shared.aggregation.updateTransaction(transactionID: transaction.transactionID) { (error) in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.containerView.isHidden = false
                
                if let updateError = error {
                    print(updateError.localizedDescription)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "CategoriesSegue" {
            
        } else if segue.identifier == "" {
            
        }
    }
    
}
