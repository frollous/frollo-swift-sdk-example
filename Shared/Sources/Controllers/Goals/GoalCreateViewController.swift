//
//  GoalCreateViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 26/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

class GoalCreateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, GoalAccountOptionViewControllerDelegate {
    
    enum DatePickerMode {
        case end
        case start
    }
    
    enum GoalFields {
        case account
        case description
        case endDate
        case frequency
        case name
        case periodAmount
        case startDate
        case targetAmount
        case tracking
    }
    
    @IBOutlet var datePickerConstraint: NSLayoutConstraint!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var pickerContainerView: UIView!
    
    private let currencyFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    var datePickerMode: DatePickerMode = .start
    var fields = [GoalFields]()
    var goalAccount: Account?
    var goalDescription: String?
    var goalEndDate: Date?
    var goalFrequency: Goal.Frequency = .weekly
    var goalName: String?
    var goalPeriodAmount: Decimal?
    var goalStartDate = Date()
    var goalTarget: Goal.Target = .amount
    var goalTargetAmount: Decimal?
    var goalTrackingType: Goal.TrackingType = .credit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem?.title = "Back"
        
        datePicker.minimumDate = Date()

        fields = [.name, .description, .account, .tracking, .frequency, .targetAmount, .periodAmount, .startDate, .endDate]
        
        switch goalTarget {
            case .amount:
                fields.removeAll { (field) -> Bool in
                    return field == .endDate
                }
                navigationItem.title = "Add Amount Goal"
            case .date:
                fields.removeAll { (field) -> Bool in
                    return field == .periodAmount
                }
                navigationItem.title = "Add Date Goal"
            case .openEnded:
                fields.removeAll { (field) -> Bool in
                    return field == .targetAmount
                }
                navigationItem.title = "Add Open Ended Goal"
        }
    }
    
    // MARK: - Interaction
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        switch datePickerMode {
            case .end:
                goalEndDate = sender.date
            
                tableView.reloadRows(at: [IndexPath(row: fields.firstIndex(of: .endDate) ?? 0, section: 0)], with: .automatic)
            case .start:
                goalStartDate = sender.date
            
                tableView.reloadRows(at: [IndexPath(row: fields.firstIndex(of: .startDate) ?? 0, section: 0)], with: .automatic)
        }
    }
    
    @IBAction func donePress(sender: UIBarButtonItem) {
        hideDatePicker()
    }
    
    @IBAction func savePress(sender: UIBarButtonItem) {
        createGoal()
    }
    
    // MARK: - View
    
    private func hideLoadingView() {
        loadingView.isHidden = true
        spinner.stopAnimating()
    }
    
    private func showLoadingView() {
        loadingView.isHidden = false
        spinner.startAnimating()
    }
    
    private func showError(details: String) {
        let alertController = UIAlertController(title: "Create Goal Failed", message: details, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true)
    }
    
    // MARK: - Options
    
    func hideDatePicker() {
        datePickerConstraint.constant = -pickerContainerView.frame.height
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showDatePicker(mode: DatePickerMode) {
        datePickerMode = mode
        
        datePickerConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
        
    func showFrequencyOptions() {
        let alertController = UIAlertController(title: "Frequency", message: nil, preferredStyle: .actionSheet)
        
        for frequency in Goal.Frequency.allCases {
            let alertAction = UIAlertAction(title: frequency.rawValue.capitalized, style: .default) { (action) in
                self.goalFrequency = frequency
                
                self.tableView.reloadRows(at: [IndexPath(row: self.fields.firstIndex(of: .frequency) ?? 0, section: 0)], with: .automatic)
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    func showTrackingOptions() {
        let alertController = UIAlertController(title: "Tracking Method", message: nil, preferredStyle: .actionSheet)
        
        for trackingType in Goal.TrackingType.allCases {
            let alertAction = UIAlertAction(title: trackingType.rawValue.capitalized, style: .default) { (action) in
                self.goalTrackingType = trackingType
                
                self.tableView.reloadRows(at: [IndexPath(row: self.fields.firstIndex(of: .tracking) ?? 0, section: 0)], with: .automatic)
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    func showAccountOptions() {
        let accountOptionsViewController = storyboard?.instantiateViewController(withIdentifier: "GoalAccountOptionViewController") as! GoalAccountOptionViewController
        accountOptionsViewController.delegate = self
        navigationController?.pushViewController(accountOptionsViewController, animated: true)
    }
    
    // MARK: - Goal Create and Validate
    
    func createGoal() {
        view.endEditing(true)
        hideDatePicker()
        
        guard let name = goalName
            else {
                showError(details: "Missing goal name.")
                return
        }
        
        guard let account = goalAccount
            else {
                showError(details: "No account selected.")
                return
        }
        
        switch goalTarget {
            case .amount:
                if goalTargetAmount == nil {
                    showError(details: "Missing target amount.")
                    return
                }
                if goalPeriodAmount == nil {
                    showError(details: "Missing period amount.")
                    return
                }
            
            case .date:
                if goalEndDate == nil {
                    showError(details: "Missing end date.")
                    return
                }
                if goalTargetAmount == nil {
                    showError(details: "Missing target amount.")
                    return
                }
            
            case .openEnded:
                if goalEndDate == nil {
                    showError(details: "Missing end date.")
                    return
                }
                if goalPeriodAmount == nil {
                    showError(details: "Missing period amount.")
                    return
                }
        }
        
        showLoadingView()
        
        Frollo.shared.goals.createGoal(name: name,
                                          description: goalDescription,
                                          target: goalTarget,
                                          trackingType: goalTrackingType,
                                          frequency: goalFrequency,
                                          startDate: goalStartDate,
                                          endDate: goalEndDate,
                                          periodAmount: goalPeriodAmount,
                                          targetAmount: goalTargetAmount,
                                          accountID: account.accountID) { (result) in
                                            self.hideLoadingView()
                                            
                                            switch result {
                                                case .failure(let error):
                                                    self.showError(details: error.localizedDescription)
                                                case .success:
                                                    self.dismiss(animated: true)
                                            }
        }
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = fields[indexPath.row]
        
        switch field {
            case .account:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
                
                cell.textLabel?.text = "Account"
                
                if let account = goalAccount {
                    cell.detailTextLabel?.text = account.nickName ?? account.accountName
                    cell.detailTextLabel?.textColor = UIColor.black
                } else {
                    cell.detailTextLabel?.text = "Select Account"
                    cell.detailTextLabel?.textColor = UIColor.lightGray
                }
                
                return cell
            
            
            
        case .description:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.textField.delegate = self
            cell.textField.placeholder = "Description"
            cell.textField.text = goalDescription
            
            return cell
            
        case .endDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            cell .textLabel?.text = "End Date"
            
            if let endDate = goalEndDate {
                cell.detailTextLabel?.text = dateFormatter.string(from: endDate)
                cell.detailTextLabel?.textColor = UIColor.black
            } else {
                cell.detailTextLabel?.text = "Due date"
                cell.detailTextLabel?.textColor = UIColor.lightGray
            }
            
            return cell
            
        case .frequency:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            
            cell.textLabel?.text = "Frequency"
            cell.detailTextLabel?.text = goalFrequency.rawValue.capitalized
            
            return cell
            
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.textField.delegate = self
            cell.textField.placeholder = "Name"
            cell.textField.text = goalName
            
            return cell
            
        case .periodAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell", for: indexPath) as! AmountCell
            cell.textField.delegate = self
            
            cell.textField.placeholder = "$200"
            cell.titleLabel.text = "Period Amount"
            
            if let periodAmount = goalPeriodAmount {
                cell.textField.text = currencyFormatter.string(for: periodAmount)
            } else {
                cell.textField.text = nil
            }
            
            return cell
            
        case .startDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            cell .textLabel?.text = "Start Date"
            cell.detailTextLabel?.text = dateFormatter.string(from: goalStartDate)
            
            return cell
            
        case .targetAmount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmountCell", for: indexPath) as! AmountCell
            cell.textField.delegate = self
            
            cell.textField.placeholder = "$1,000"
            cell.titleLabel.text = "Target Amount"
            
            if let targetAmount = goalTargetAmount {
                cell.textField.text = currencyFormatter.string(for: targetAmount)
            } else {
                cell.textField.text = nil
            }
            
            return cell
            
        case .tracking:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
            
            cell.textLabel?.text = "Tracking Method"
            cell.detailTextLabel?.text = goalTrackingType.rawValue.capitalized
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let field = fields[indexPath.row]
        
        switch field {
            case .account:
                showAccountOptions()
            case .endDate:
                showDatePicker(mode: .end)
            case .frequency:
                showFrequencyOptions()
            case .startDate:
                showDatePicker(mode: .start)
            case .tracking:
                showTrackingOptions()
            default:
                break
        }
    }
    
    // MARK: - String Manipulation
    
    private func stripCurrencyString(string: String) -> String {
        let characterSet = CharacterSet.decimalDigits.inverted
        var strippedString = string.trimmingCharacters(in: characterSet)
        strippedString = strippedString.replacingOccurrences(of: currencyFormatter.groupingSeparator, with: "")
        return strippedString
    }
    
    // MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text as NSString?
        let proposedString = currentString?.replacingCharacters(in: range, with: string)
        
        var field: GoalFields = .name
        
        if let cell = textField.superview?.superview as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            field = fields[indexPath.row]
        }
        
        switch field {
            case .periodAmount, .targetAmount:
                if proposedString == nil || proposedString == "" {
                    return true
                }
                
                let strippedProposedString = stripCurrencyString(string: proposedString!)
                let value = NSDecimalNumber(string: strippedProposedString)
                
                guard value != NSDecimalNumber.notANumber
                    else {
                        return false
                }
                textField.text = currencyFormatter.string(from: value)
                
                if field == .periodAmount {
                    goalPeriodAmount = value as Decimal
                } else {
                    goalTargetAmount = value as Decimal
                }
                
                return false
            case .name:
                goalName = proposedString
            
            case .description:
                goalDescription = proposedString
            
            default:
                break
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    // MARK: - Account Option Delegate
    
    func selectedAccount(_ account: Account) {
        goalAccount = account
        
        tableView.reloadRows(at: [IndexPath(row: fields.firstIndex(of: .account) ?? 0, section: 0)], with: .automatic)
        
        navigationController?.popToViewController(self, animated: true)
    }

}
