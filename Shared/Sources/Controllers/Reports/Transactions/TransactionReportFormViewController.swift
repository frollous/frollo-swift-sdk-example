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
    var transactionReportFormFilter: String? { get }
    var transactionReportFormFilterBy: String? { get }
    var transactionReportFormGrouping: String? { get }
    var transactionReportFormPeriod: String? { get }
    
    func selectionItems(forField field: TransactionReportFormViewController.FormField) -> [SelectionDisplayable]
    func selectedIndex(forField field: TransactionReportFormViewController.FormField) -> Int?
}

protocol TransactionReportFormViewControllerDelegate: AnyObject {
    func didSelectIndex(index: Int, forField field: TransactionReportFormViewController.FormField)
}

class TransactionReportFormViewController: UITableViewController {
    
    enum FormField: Int {
        case filter
        case filterBy
        case grouping
        case period
    }
    
    public var current = false
    
    var dataSource: TransactionReportFormViewControllerDataSource? {
        didSet {
            updateView()
        }
    }
    
    weak var delegate: TransactionReportFormViewControllerDelegate?
    
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var filterbyLabel: UILabel!
    @IBOutlet var groupingLabel: UILabel!
    @IBOutlet var periodLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        filterLabel?.text = dataSource?.transactionReportFormFilter
        filterbyLabel?.text = dataSource?.transactionReportFormFilterBy
        groupingLabel?.text = dataSource?.transactionReportFormGrouping
        periodLabel?.text = dataSource?.transactionReportFormPeriod
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let field = FormField(rawValue: indexPath.row) else { return }
        showSelection(field: field)
    }
    
    func showSelection(field: TransactionReportFormViewController.FormField) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectionTableViewController") as! SelectionTableViewController
        viewController.field = field
        viewController.selectedIndex = dataSource?.selectedIndex(forField: field)
        viewController.dataSource = self
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
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
