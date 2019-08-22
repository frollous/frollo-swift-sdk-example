//
//  GoalDetailsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 30/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class GoalDetailsViewController: TableViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var periodAmountLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    
    internal var goalID: Int64 = -1
    
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
    
    private var fetchedResultsController: NSFetchedResultsController<GoalPeriod>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = Frollo.shared.database.viewContext
        
        if let goal = Frollo.shared.goals.goal(context: context, goalID: goalID) {
            nameLabel.text = goal.name
            frequencyLabel.text = goal.frequency.rawValue.capitalized
            periodAmountLabel.text = currencyFormatter.string(from: goal.periodAmount)
        }
        
        let predicate = NSPredicate(format: #keyPath(GoalPeriod.goalID) + " == %ld", argumentArray: [goalID])
        fetchedResultsController = Frollo.shared.goals.goalPeriodsFetchedResultsController(context: context, filteredBy: predicate, sortedBy: [NSSortDescriptor(key: #keyPath(GoalPeriod.startDateString), ascending: true)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Frollo.shared.goals.refreshGoalPeriods(goalID: goalID) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    self.reloadData()
            }
        }
        
        reloadData()
    }
    
    // MARK: - Interaction
    
    @IBAction func deletePress(sender: UIBarButtonItem) {
        showDeleteGoalAlert()
    }
    
    // MARK: - Goal
    
    private func showDeleteGoalAlert() {
        let alertController = UIAlertController(title: "Abandon Goal", message: "Are you sure you wish to abandon the goal?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Abandon", style: .destructive) { (action) in
            self.deleteGoal()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteGoal() {
        Frollo.shared.goals.deleteGoal(goalID: goalID) { (result) in
            switch result {
                case .failure(let error):
                    self.showError(details: error.localizedDescription)
                case .success:
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showError(details: String) {
        let alertController = UIAlertController(title: "Create Goal Failed", message: details, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true)
    }
    
    // MARK: - Goal Periods
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodCell", for: indexPath) as! GoalPeriodCell
        
        let period = fetchedResultsController.object(at: indexPath)
        
        cell.startDateLabel.text = "Start " + dateFormatter.string(for: period.startDate)!
        cell.endDateLabel.text = "End " + dateFormatter.string(for: period.endDate)!
        cell.targetAmountLabel.text = "Target: " + currencyFormatter.string(for: period.targetAmount)!
        cell.requiredAmountLabel.text = "Required: " + currencyFormatter.string(from: period.requiredAmount)!
        cell.currentAmountLabel.text = "Current: " + currencyFormatter.string(from: period.currentAmount)!
        
        if let trackingStatus = period.trackingStatus {
            cell.statusLabel.isHidden = false
            
            switch trackingStatus {
                case .ahead:
                    cell.statusLabel.text = "Ahead"
                    cell.statusLabel.textColor = UIColor.green
                case .behind:
                    cell.statusLabel.text = "Behind"
                    cell.statusLabel.textColor = UIColor.red
                case .onTrack:
                    cell.statusLabel.text = "On Track"
                    cell.statusLabel.textColor = UIColor.orange
            }
        } else {
            cell.statusLabel.isHidden = true
        }
        
        return cell
    }

}
