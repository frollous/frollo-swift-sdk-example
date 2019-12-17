//
//  BudgetDetailsViewController.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 5/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK
import CoreData

class BudgetDetailsViewController: TableViewController {
    
    internal var budgetID: Int64 = -1
    private var fetchedResultsController: NSFetchedResultsController<BudgetPeriod>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = Frollo.shared.database.viewContext
        fetchedResultsController = Frollo.shared.budgets.budgetPeriodsFetchedResultsController(context: context, budgetID: budgetID, sortedBy: [NSSortDescriptor(key: #keyPath(BudgetPeriod.startDateString), ascending: true)])
        fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.budgets.refreshBudgetPeriods(budgetID: budgetID) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }
    
    private func reloadData() {
           do {
               try fetchedResultsController.performFetch()
           } catch {
               print(error.localizedDescription)
           }
           
           tableView.reloadData()
       }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        showDeleteBudgetAlert()
    }
    
    @IBAction func updateButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Budgets", bundle: nil)
        let budgetListViewController = storyboard.instantiateViewController(withIdentifier: "BudgetCreateViewController")
        self.navigationController?.pushViewController(budgetListViewController, animated: true)
    }
    
    private func showDeleteBudgetAlert() {
        let alertController = UIAlertController(title: "Delete Budget", message: "Are you sure you wish to delete the budget?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteBudget()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteBudget() {
        Frollo.shared.budgets.deleteBudget(budgetID: budgetID) { (result) in
            switch result {
                case .failure(let error):
                    self.showError(details: error.localizedDescription)
                case .success:
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension BudgetDetailsViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetPeriodCell", for: indexPath) as! BudgetPeriodCell
        
        let budgetPeriod = fetchedResultsController.object(at: indexPath)
        cell.bugdetPeriodStartDateLabel.text = "Start: \(budgetPeriod.startDateString)"
        cell.bugdetPeriodEndDateLabel.text = "End: \(budgetPeriod.endDateString)"
        cell.bugdetPeriodCurrentAmountLabel.text = "Current: \(budgetPeriod.currentAmount)"
        cell.bugdetPeriodTargetAmountLabel.text = "Target: \(budgetPeriod.targetAmount)"
        cell.budgetPeriodStatusLabel.text = budgetPeriod.trackingStatus?.rawValue ?? ""

        return cell
    }

    
}
