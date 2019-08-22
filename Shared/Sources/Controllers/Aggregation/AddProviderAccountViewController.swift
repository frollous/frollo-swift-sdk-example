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

class AddProviderAccountViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate, AddProviderChoiceCellDelegate {
    
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
    
    // MARK: - Interaction
    
    @IBAction func donePress(sender: UIBarButtonItem) {
        guard let viewModel = loginFormViewModel,
            let provider = fetchedProvider
            else {
                return
        }
        
        let viewModelValidationResult = viewModel.validateMultipleChoice()
        
        guard viewModelValidationResult.0 == true
            else {
                return
        }
        
        var filledDataModel = viewModel.dataModel()
        
        let validationResult = filledDataModel.validateForm()
        
        guard validationResult.0 == true
            else {
                return
        }
        
        spinner.startAnimating()
        tableView.isHidden = true
        
        // Encrypt the fields with the provider public key if available
        if let encryptionAlias = provider.encryptionAlias, let encryptionKey = provider.encryptionPublicKey {
            filledDataModel.encryptValues(encryptionKey: encryptionKey, encryptionAlias: encryptionAlias)
        }
        
        Frollo.shared.aggregation.createProviderAccount(providerID: providerID, loginForm: filledDataModel) { (result) in
            self.tableView.isHidden = false
            self.spinner.stopAnimating()
            
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success:
                    self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Provider Login Form
    
    private func reloadData() {
        fetchProvider()
        
        reloadLoginForm()
    }
    
    private func refreshProvider() {
        Frollo.shared.aggregation.refreshProvider(providerID: providerID) { (result) in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    self.navigationController?.popViewController(animated: true)
                case .success:
                    self.reloadData()
            }
        }
    }
    
    private func fetchProvider() {
        let context = Frollo.shared.database.viewContext
        fetchedProvider = Frollo.shared.aggregation.provider(context: context, providerID: providerID)
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
            } else if let row = modelCell.rows.first, let field = row.field.first {
                let fieldCell = tableView.dequeueReusableCell(withIdentifier: "FieldCell", for: indexPath) as! AddProviderLoginFieldCell
                
                fieldCell.titleLabel.text = row.label
                fieldCell.textField.delegate = self
                fieldCell.textField.autocorrectionType = .no
                fieldCell.textField.autocapitalizationType = .none
                fieldCell.textField.placeholder = row.hint
                fieldCell.textField.text = field.value
                
                switch field.type {
                    case .password:
                        fieldCell.textField.keyboardType = .default
                        fieldCell.textField.isSecureTextEntry = true
                    
                    case .text:
                        fieldCell.textField.keyboardType = .default
                        fieldCell.textField.isSecureTextEntry = false
                    
                    default:
                        break
                }
                
                cell = fieldCell
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
    
    func cellChoiceFieldValueChanged(sender: AddProviderChoiceCell, fieldIndex: Int, updatedText: String?) {
        if let indexPath = tableView.indexPath(for: sender), let formCell = loginFormViewModel?.cells[indexPath.row] {
            var index = 0
            
            for row in formCell.rows {
                if row.id == formCell.selectedRowID! {
                    loginFormViewModel?.cells[indexPath.row].rows[index].field[fieldIndex].value = updatedText
                    break
                }
                
                index += 1
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text as NSString?
        let proposedString = currentString?.replacingCharacters(in: range, with: string)
        
        let cell = textField.superview?.superview?.superview as! AddProviderLoginFieldCell
        
        let indexPath = tableView.indexPath(for: cell)!
        
        if let field = loginFormViewModel?.cells[indexPath.row].rows[0].field[0] {
            if let checkString = proposedString, let maxChars = field.maxLength {
                if checkString.count > maxChars {
                    return false
                }
            }
            
            loginFormViewModel?.cells[indexPath.row].rows[0].field[0].value = proposedString
        }
        
        return true
    }

}
