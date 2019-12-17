//
//  TransactionReportFormViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 6/2/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

protocol TransactionReportFormViewControllerDataSource: AnyObject {
    func selectionItems(forField field: TransactionReportFormViewController.FormField) -> [SelectionDisplayable]
    func selectedIndex(forField field: TransactionReportFormViewController.FormField) -> Int?
    func selectedText(forField field: TransactionReportFormViewController.FormField) -> String?
}

protocol TransactionReportFormViewControllerDelegate: AnyObject {
    func didSelectIndex(index: Int, forField field: TransactionReportFormViewController.FormField)
    func submitDidPress(completion: @escaping ([ReportItemDisplayable]) -> Void)
}

class TransactionReportFormViewController: UITableViewController {
    
    enum FormField: Int, CaseIterable {
        case filter
        case filterBy
        case grouping
        case period
        
        var title: String {
            switch self {
            case .filter:
                return "Filter"
            case .filterBy:
                return "Filter By"
            case .grouping:
                return "Grouping"
            case .period:
                return "Period"
            }
        }
    }
    
    public var current = false
    
    var dataSource: TransactionReportFormViewControllerDataSource? {
        didSet {
            updateView()
        }
    }
    
    weak var delegate: TransactionReportFormViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        tableView.reloadData()
    }
    
    @IBAction func submitDidPress() {
        delegate?.submitDidPress(completion: { (items) in
            self.showReportResults(items: items)
        })
    }
    
    func showSelection(field: TransactionReportFormViewController.FormField) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectionTableViewController") as! SelectionTableViewController
        viewController.field = field
        viewController.selectedIndex = dataSource?.selectedIndex(forField: field)
        viewController.dataSource = self
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showReportResults(items: [ReportItemDisplayable]) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "TransactionsReportTableViewController") as! TransactionsReportTableViewController
        viewController.data = items
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FormField.allCases.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let field = FormField(rawValue: indexPath.row) else { return }
        showSelection(field: field)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ReportFormItemTableViewCell
        let field = FormField.allCases[indexPath.row]
        cell.titleLabel.text = field.title
        cell.valueLabel.text = dataSource?.selectedText(forField: field)
        return cell
    }
}

extension TransactionReportFormViewController: SelectionTableViewControllerDataSource {
    
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, itemsForField type: TransactionReportFormViewController.FormField) -> [SelectionDisplayable] {
        return dataSource?.selectionItems(forField: type) ?? []
    }
}

extension TransactionReportFormViewController: SelectionTableViewControllerDelegate {
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, formField: TransactionReportFormViewController.FormField, didSelectItemAt index: Int) {
        delegate?.didSelectIndex(index: index, forField: formField)
        updateView()
        navigationController?.popViewController(animated: true)
    }
}
