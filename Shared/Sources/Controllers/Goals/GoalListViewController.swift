//
//  GoalListViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 30/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class GoalListViewController: TableViewController {
    
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
    
    private var fetchedResultsController: NSFetchedResultsController<Goal>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let context = FrolloSDK.shared.database.viewContext
        fetchedResultsController = FrolloSDK.shared.goals.goalsFetchedResultsController(context: context, status: .active, sortedBy: [NSSortDescriptor(key: #keyPath(Goal.endDateString), ascending: true)])
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.goals.refreshGoals(status: .active) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    break
            }
        }
        
        reloadData()
    }
    
    // MARK: - Goals
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalListCell", for: indexPath) as! GoalListCell
        
        let goal = fetchedResultsController.object(at: indexPath)
        
        cell.nameLabel.text = goal.name
        cell.detailsLabel.text = goal.details
        cell.frequencyLabel.text = goal.frequency.rawValue.capitalized
        cell.endDateLabel.text = dateFormatter.string(from: goal.endDate)
        cell.targetLabel.text = goal.target.rawValue.capitalized
        cell.targetAmountLabel.text = "Target: " + currencyFormatter.string(for: goal.targetAmount)!
        cell.currentAmountLabel.text = "Saved: " + currencyFormatter.string(from: goal.currentAmount)!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = fetchedResultsController.object(at: indexPath)
        
        let goalDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "GoalDetailsViewController") as! GoalDetailsViewController
        goalDetailsViewController.goalID = goal.goalID
        navigationController?.pushViewController(goalDetailsViewController, animated: true)
    }

}
