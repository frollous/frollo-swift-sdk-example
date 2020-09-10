//
//  MoreViewController.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 5/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class MoreViewTableController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GoalListViewController")  as! GoalListViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 1 {
            let storyboard = UIStoryboard(name: "Surveys", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SurveyViewController")  as! SurveyViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.item == 2 {
            let storyboard = UIStoryboard(name: "Budgets", bundle: nil)
            let budgetListViewController = storyboard.instantiateViewController(withIdentifier: "BudgetListViewController")
            self.navigationController?.pushViewController(budgetListViewController, animated: true)
        } else if indexPath.item == 3 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let transactionPaginationViewController = storyboard.instantiateViewController(withIdentifier: "TransactionPaginationViewController")
            self.navigationController?.pushViewController(transactionPaginationViewController, animated: true)
            
        }
        
    }

}
