//
//  AddProviderAccountViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 31/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import CoreData
import UIKit

import FrolloSDK

class AddProviderAccountViewController: UIViewController, UITableViewDataSource, AddProviderChoiceCellDelegate {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    
    public var providerID: Int64!
    
    private var fetchedProvider: Provider?
    private var loginFormViewModel: ProviderLoginFormViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshProvider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - Provider Login Form
    
    private func reloadData() {
        fetchProvider()
        
        reloadLoginForm()
    }
    
    private func refreshProvider() {
        FrolloSDK.shared.aggregation.refreshProvider(providerID: providerID) { (error) in
            if let refreshError = error {
                print(refreshError.localizedDescription)
                
                self.navigationController?.popViewController(animated: true)
            } else {
                self.reloadData()
            }
        }
    }
    
    private func fetchProvider() {
        let context = FrolloSDK.shared.database.viewContext
        fetchedProvider = FrolloSDK.shared.aggregation.provider(context: context, providerID: providerID)
    }
    
    private func reloadLoginForm() {
        guard let provider = fetchedProvider,
            let loginForm = provider.loginForm
            else {
                return
        }
        
        loginFormViewModel = ProviderLoginFormViewModel(loginForm: loginForm)
        
        tableView.reloadData()
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard loginFormViewModel != nil
            else {
                return 0
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = loginFormViewModel
            else {
                return 0
        }
        
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if let viewModel = loginFormViewModel {
            let modelCell = viewModel.cells[indexPath.row]
            
            if modelCell.rows.count > 1 {
                let choiceCell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell", for: indexPath) as! AddProviderChoiceCell
                choiceCell.delegate = self
                choiceCell.updateChoices(modelCell)
                
                cell = choiceCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "BlankCell", for: indexPath)
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "BlankCell", for: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Delegates
    
    func cellChoiceChanged(cell: AddProviderChoiceCell, choiceIndex: Int) {
        guard var viewModel = loginFormViewModel
            else {
                return
        }
        
        if let indexPath = tableView.indexPath(for: cell) {
            var currentIndex = 0
            
            for row in viewModel.cells[indexPath.row].rows {
                if currentIndex == choiceIndex {
                    loginFormViewModel?.cells[indexPath.row].selectedRowID = row.id
                }
                
                currentIndex += 1
            }
            
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

}
