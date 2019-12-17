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
    
    func selectionItems(forType: TransactionReportFormViewController.FormField) -> [SelectionDisplayable]
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
        showSelection(type: field)
    }
    
    func showSelection(type: TransactionReportFormViewController.FormField) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectionTableViewController") as! SelectionTableViewController
        viewController.type = type
        viewController.dataSource = self
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension TransactionReportFormViewController: SelectionTableViewControllerDataSource {
    
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, itemsForType type: TransactionReportFormViewController.FormField) -> [SelectionDisplayable] {
        return dataSource?.selectionItems(forType: type) ?? []
    }
}

extension TransactionReportFormViewController: SelectionTableViewControllerDelegate {
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, formField: TransactionReportFormViewController.FormField, didSelectItemAt index: Int) {
        delegate?.didSelectIndex(index: index, forField: formField)
        navigationController?.popViewController(animated: true)
    }
}
