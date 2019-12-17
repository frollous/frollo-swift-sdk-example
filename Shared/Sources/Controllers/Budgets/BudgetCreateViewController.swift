//
//  BudgetCreateViewController.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 5/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK

class BudgetCreateViewController: BaseViewController {
    
    enum BudgetFields {
        case frequency
        case imageURLString
        case periodAmount
        case type
        case typeValue
        case startDate
    }
    
    @IBOutlet var saveButtonItem: UIBarButtonItem!
    @IBOutlet var createBudgetTableView: UITableView!
    @IBOutlet var datePickerConstraint: NSLayoutConstraint!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var pickerContainerView: UIView!
    
    var tableFields: [BudgetFields] = [.frequency, .imageURLString, .periodAmount, .type, .typeValue, .startDate]
    var budgetFrequency: Budget.Frequency = .weekly
    var imageURLString: String?
    var type: Budget.BudgetType?
    var typeValue: String?
    var periodAmount: Decimal?
    var budgetCreateType: BudgetCreateType = .budgetCategory(budgetCategory: .living)
    
    var budgetStartDate: Date?
    var update = false
    var budgetID: Int64 = -1
    let context = Frollo.shared.database.viewContext
    var budget: Budget?
    
    private let currencyFormatter: NumberFormatter = {
           let numberFormatter = NumberFormatter()
           numberFormatter.locale = Locale.autoupdatingCurrent
           numberFormatter.numberStyle = .currency
           numberFormatter.maximumFractionDigits = 0
           return numberFormatter
       }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    private func stripCurrencyString(string: String) -> String {
        let characterSet = CharacterSet.decimalDigits.inverted
        var strippedString = string.trimmingCharacters(in: characterSet)
        strippedString = strippedString.replacingOccurrences(of: currencyFormatter.groupingSeparator, with: "")
        return strippedString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if update {
            budget = Frollo.shared.budgets.budget(context: context, budgetID: budgetID)
            saveButtonItem.title = "Update"
            periodAmount = budget?.periodAmount as Decimal?
            imageURLString = budget?.imageURLString
            tableFields = [.imageURLString, .periodAmount]
            createBudgetTableView.reloadData()
        }
    }
    
    // MARK: -  Interactions
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if update {
            updateBudget()
        } else {
            createBudget()
        }
        
    }
    
    // MARK: -  API calls
    
    func updateBudget() {
                   
        context.performAndWait {
            
            guard let newPeriodAmount = periodAmount
                else {
                    showError(details: "Period Amount is not valid.")
                    return
            }
            
            showProgress()
                        
            budget?.imageURLString = imageURLString
            budget?.periodAmount = NSDecimalNumber(decimal: newPeriodAmount)
            
            try? context.save()
        }
        
        Frollo.shared.budgets.updateBudget(budgetID: budgetID){ (result) in
            self.handleResult(result: result)
        }
    }
    
    func createBudget() {
        guard let budgetPeriodAmount = periodAmount
            else {
                showError(details: "Period Amount is missing.")
                return
        }
        
        var startDateString : String?
        if let startDate = budgetStartDate {
            startDateString = dateFormatter.string(from: startDate)
        }
        
        showProgress()
        
        switch budgetCreateType {
        case .budgetCategory(let budgetCategory):
            Frollo.shared.budgets.createBudgetCategoryBudget(budgetCategory: budgetCategory, frequency: budgetFrequency, periodAmount: budgetPeriodAmount, startDate: startDateString){ (result) in
                self.handleResult(result: result)
            }
        case .category(let categoryID):
            Frollo.shared.budgets.createCategoryBudget(categoryID: categoryID, frequency: budgetFrequency, periodAmount: budgetPeriodAmount, startDate: startDateString){ (result) in
                self.handleResult(result: result)
            }
        case .merchant(let merchantID):
            Frollo.shared.budgets.createMerchantBudget(merchantID: merchantID, frequency: budgetFrequency, periodAmount: budgetPeriodAmount, startDate: startDateString){ (result) in
                self.handleResult(result: result)
            }
        }
    }
    
    func handleResult(result: EmptyResult<Error>) {
        self.hideProgress()
                   
        switch result {
        case .failure(let error):
            self.showError(details: error.localizedDescription)
        case .success:
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: -  Popup Options
    
    func showFrequencyOptions() {
        let alertController = UIAlertController(title: "Frequency", message: nil, preferredStyle: .actionSheet)
        
        for frequency in Budget.Frequency.allCases {
            let alertAction = UIAlertAction(title: frequency.rawValue.capitalized, style: .default) { (action) in
                self.budgetFrequency = frequency
                
                self.createBudgetTableView.reloadRows(at: [IndexPath(row: self.tableFields.firstIndex(of: .frequency) ?? 0, section: 0)], with: .automatic)
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    func showBudgetTypeOptions() {
        let alertController = UIAlertController(title: "Budget Type", message: nil, preferredStyle: .actionSheet)
        
        for budgetType in BudgetCreateType.allCases {
            let alertAction = UIAlertAction(title: budgetType.rawValue.capitalized, style: .default) { (action) in
                self.budgetCreateType = budgetType
                self.createBudgetTableView.reloadData()
                self.showValuePopup()
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    func showBudgetCategoryOptions() {
        let alertController = UIAlertController(title: "Budget Category", message: nil, preferredStyle: .actionSheet)
        
        for budgetCategory in BudgetCategory.allCases {
            let alertAction = UIAlertAction(title: budgetCategory.rawValue.capitalized, style: .default) { (action) in
                self.budgetCreateType = .budgetCategory(budgetCategory: budgetCategory)
                self.createBudgetTableView.reloadData()
            }
            alertController.addAction(alertAction)
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: -  Navigations
    
    func showValuePopup() {
        switch budgetCreateType {
        case .budgetCategory:
            showBudgetCategoryOptions()
        case .category:
            showTransacationCategories()
        case .merchant:
            showMerchants()
        }
    }
    
    func showTransacationCategories() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionCategoriesViewController = mainStoryboard.instantiateViewController(withIdentifier: "TransactionCategoriesViewController") as! TransactionCategoriesViewController
        transactionCategoriesViewController.delegate = self
         self.navigationController?.pushViewController(transactionCategoriesViewController, animated: true)
        
    }
    
    func showMerchants() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let merchantsViewController = mainStoryboard.instantiateViewController(withIdentifier: "MerchantsViewController") as! MerchantsViewController
        merchantsViewController.delegate = self
         self.navigationController?.pushViewController(merchantsViewController, animated: true)
        
    }
    
    // MARK: -  Date Picker functions
    
    func hideDatePicker() {
        datePickerConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showDatePicker() {        
        datePickerConstraint.constant = -260
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        budgetStartDate = sender.date
        createBudgetTableView.reloadData()
    }
       
    @IBAction func donePress(sender: UIBarButtonItem) {
        hideDatePicker()
    }
}

extension BudgetCreateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return tableFields.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let field = tableFields[indexPath.row]
           
           switch field {
               
           case .frequency:
               let cell = tableView.dequeueReusableCell(withIdentifier: "FrequencyCell", for: indexPath)
               cell.textLabel?.text = "Frequency"
               cell.detailTextLabel?.text = budgetFrequency.rawValue.capitalized
               
               return cell
               
           case .imageURLString:
               let cell = tableView.dequeueReusableCell(withIdentifier: "ImageURLCell", for: indexPath) as! TextFieldCell
               cell.textField.delegate = self
               cell.textField.tag = 0
               cell.textField.placeholder = "http://www.example.com/test.png"
               cell.textField.text = imageURLString
               
               return cell
               
           case .periodAmount:
               let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodAmountCell", for: indexPath) as! AmountCell
               cell.textField.delegate = self
               cell.textField.tag = 1
               cell.textField.placeholder = "$200"
               cell.titleLabel.text = "Period Amount"
               
               if let periodAmount = periodAmount {
                   cell.textField.text = currencyFormatter.string(for: periodAmount)
               } else {
                   cell.textField.text = nil
               }
               
               return cell
            
           case .type:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
                cell.textLabel?.text = "Budget Type"
                cell.detailTextLabel?.text = budgetCreateType.rawValue
                return cell
            
           case .typeValue:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TypeValueCell", for: indexPath)
                
                switch budgetCreateType {
                case .budgetCategory(let budgetCategory):
                    cell.textLabel?.text = "Budget category"
                    cell.detailTextLabel?.text = budgetCategory.rawValue
                case .category(let categoryID):
                    cell.textLabel?.text = "Category ID"
                    cell.detailTextLabel?.text = "\(categoryID)"
                case .merchant(let merchantID):
                    cell.textLabel?.text = "Merchant"
                    cell.detailTextLabel?.text = "\(merchantID)"
                }
                return cell
            
            case .startDate:
                let cell = tableView.dequeueReusableCell(withIdentifier: "StartDateCell", for: indexPath)
                cell.textLabel?.text = "Start Date"
                
                if let startDate = budgetStartDate {
                    cell.detailTextLabel?.text = dateFormatter.string(from: startDate)
                }
                
                return cell
        }

       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
            self.view.endEditing(true)
           let field = tableFields[indexPath.row]
        
            switch field {
                case .type:
                    showBudgetTypeOptions()
            
                case .frequency:
                    showFrequencyOptions()
                
                case .typeValue:
                    showValuePopup()
                
                case .startDate:
                    showDatePicker()
            
                default:
                break
        }
           
       }
    
}

extension BudgetCreateViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let currentString = textField.text as NSString?
           let proposedString = currentString?.replacingCharacters(in: range, with: string)
        
        if textField.tag == 0{
            imageURLString = proposedString
        } else if textField.tag == 1 {
            
            let strippedProposedString = stripCurrencyString(string: proposedString!)
            let value = NSDecimalNumber(string: strippedProposedString)
            
            if value != NSDecimalNumber.notANumber {
                textField.text = currencyFormatter.string(from: value)
                periodAmount = value as Decimal
                return false
            } else {
                return true
            }
            
        } else {
            typeValue = proposedString
        }
        
        return true
       }
       
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           
           return false
       }
}


extension BudgetCreateViewController: TransactionCategoryDelegate {
    
    func transactionCatrgoryDidSelect(transactionCategory: TransactionCategory) {
        budgetCreateType = .category(categoryID: transactionCategory.transactionCategoryID)
        createBudgetTableView.reloadData()
    }
        
}

extension BudgetCreateViewController: MerchantDelegate {
    
    func merchantDidselect(merchant: Merchant) {
        budgetCreateType = .merchant(merchantID: merchant.merchantID)
        createBudgetTableView.reloadData()
    }
        
}
