//
//  BudgetsViewController.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 5/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK
import CoreData

class BudgetListViewController: TableViewController {
        
    private var fetchedResultsController: NSFetchedResultsController<Budget>!
    
    override func viewDidLoad() {
       super.viewDidLoad()

        let context = Frollo.shared.database.viewContext
        fetchedResultsController = Frollo.shared.budgets.budgetsFetchedResultsController(context: context, current: true, trackingType: .debitCredit, sortedBy: [NSSortDescriptor(key: #keyPath(Budget.startDateString), ascending: true)], limit: 200)
        fetchedResultsController.delegate = self

   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.budgets.refreshBudgets() { (result) in
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
    
    @IBAction func addButtonDidTap(_ sender: Any) {
        showCreateBudget()
    }
    
    func showCreateBudget(update: Bool = false, budgetID: Int64 = -1) {
        let storyboard = UIStoryboard(name: "Budgets", bundle: nil)
        let budgetListViewController = storyboard.instantiateViewController(withIdentifier: "BudgetCreateViewController") as! BudgetCreateViewController
        budgetListViewController.update = update
        budgetListViewController.budgetID = budgetID
        self.navigationController?.pushViewController(budgetListViewController, animated: true)
    }
    
}


extension BudgetListViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell", for: indexPath) as! BudgetCell
        
        let budget = fetchedResultsController.object(at: indexPath)
        cell.bugdetTypeLabel.text = budget.budgetType.rawValue
        cell.bugdetValueLabel.text = budget.typeValue
        cell.budgetFrequencyLabel.text = budget.frequency.rawValue
        cell.budgetStartDateLabel.text = budget.startDateString
        cell.budgetTargetAmountLabel.text = "Period: \(budget.periodAmount)"
        cell.budgetCurrentAmountLabel.text = "Current: \(budget.currentAmount)"
        
        if let imageURL = budget.imageURLString {
            cell.budgetImageView.downloaded(from: imageURL)
        } else {
            cell.budgetImageView.image = nil
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let budget = fetchedResultsController.object(at: indexPath)
        
        let budgetDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "BudgetDetailsViewController") as! BudgetDetailsViewController
        budgetDetailsViewController.budgetID = budget.budgetID
        navigationController?.pushViewController(budgetDetailsViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let updateAction = UITableViewRowAction(style: .default, title: "Update", handler: { (action, indexPath) in
            let budget = self.fetchedResultsController.object(at: indexPath)
            self.showCreateBudget(update: true, budgetID: budget.budgetID)
        })

        return [updateAction]
    }
    
}
