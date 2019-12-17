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
    var transactionReportFormFilter: String? { set get }
    var transactionReportFormFilterBy: String? { set get }
    var transactionReportFormGrouping: String? { set get }
    var transactionReportFormPeriod: String? { set get }
}

protocol TransactionReportFormViewControllerDelegate: AnyObject {
    func didSelectFilterAt(index: Int)
    func didSelectFilterByAt(index: Int)
    func didSelectGroupingAt(index: Int)
    func didSelectPeriodAt(index: Int)
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
    
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var filterbyLabel: UILabel!
    @IBOutlet var groupingLabel: UILabel!
    @IBOutlet var periodLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateView() {
        filterLabel?.text = dataSource?.transactionReportFormFilter
        filterbyLabel?.text = dataSource?.transactionReportFormFilterBy
        groupingLabel.text = dataSource?.transactionReportFormGrouping
        periodLabel.text = dataSource?.transactionReportFormPeriod
    }
    
    func selectionType(from formField: FormField) -> SelectionTableViewController.SelectionType {
        switch formField {
        case .filter:
            return .filter
        case .filterBy:
            return .filterBy
        case .grouping:
            return .grouping
        case .period:
            return .period
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let field = FormField(rawValue: indexPath.row) else { return }
        showSelection(type: selectionType(from: field))
    }
    
    func showSelection(type: SelectionTableViewController.SelectionType) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "SelectionTableViewController") as! SelectionTableViewController
        viewController.type = type
        viewController.dataSource = self
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension TransactionReportFormViewController: SelectionTableViewControllerDataSource {
    
    struct MockSelection: SelectionDisplayable {
        var title: String? {
            return "hala"
        }
    }
    
    func selectionTableViewController(_ selectionTableViewController: SelectionTableViewController, itemsForType: SelectionTableViewController.SelectionType) -> [SelectionDisplayable] {
        return [MockSelection(), MockSelection()]
    }
    
    
}
