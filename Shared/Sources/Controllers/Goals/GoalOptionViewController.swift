//
//  GoalOptionViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 29/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

protocol GoalAccountOptionViewControllerDelegate: class {
    
    func selectedAccount(_ account: Account)
    
}

class GoalAccountOptionViewController: UITableViewController {
    
    var accounts = [Account]()
    
    weak var delegate: GoalAccountOptionViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Select Account"
        
        reloadData()
    }
    
    // MARK: - Data
    
    private func reloadData() {
        let context = FrolloSDK.shared.database.viewContext
        
        if let fetchedAccounts = FrolloSDK.shared.aggregation.accounts(context: context) {
            accounts = fetchedAccounts
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        
        let account = accounts[indexPath.row]
        
        cell.textLabel?.text = account.nickName ?? account.accountName
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        
        delegate?.selectedAccount(account)
    }

}
