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
        fetchedResultsController = Frollo.shared.budgets.budgetsFetchedResultsController(context: context, status: .active, sortedBy: [NSSortDescriptor(key: #keyPath(Budget.startDateString), ascending: true)])
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
        let storyboard = UIStoryboard(name: "Budgets", bundle: nil)
        let budgetListViewController = storyboard.instantiateViewController(withIdentifier: "BudgetCreateViewController")
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
        cell.bugdetTitleLabel.text = budget.budgetType.rawValue
        cell.bugdetSubTitleLabel.text = budget.typeValue

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let budget = fetchedResultsController.object(at: indexPath)
        
        let budgetDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "BudgetDetailsViewController") as! BudgetDetailsViewController
        budgetDetailsViewController.budgetID = budget.budgetID
        navigationController?.pushViewController(budgetDetailsViewController, animated: true)
    }
    
}
