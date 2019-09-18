//
//  GoalTargetViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 26/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit

class GoalTargetViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = "BacK"
    }
    
    // MARK: - Interaction
    
    @IBAction func cancelPress(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "GoalCreateViewController") as! GoalCreateViewController
        
        switch indexPath.row {
            case 0:
                // Amount target
                viewController.goalTarget = .amount
            case 1:
                // Date target
                viewController.goalTarget = .date
            case 2:
                // Open Ended target
                viewController.goalTarget = .openEnded
            default:
                return
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}
