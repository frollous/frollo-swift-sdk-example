//
//  GoalsViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 8/4/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

class GoalsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FrolloSDK.shared.goals.refreshGoals()
        FrolloSDK.shared.goals.refreshUserGoals()
        FrolloSDK.shared.challenges.refreshChallenges()
        
        let context = FrolloSDK.shared.database.viewContext
        let fetchedGoals = FrolloSDK.shared.goals.userGoals(context: context)
        
        print(fetchedGoals)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    

}
