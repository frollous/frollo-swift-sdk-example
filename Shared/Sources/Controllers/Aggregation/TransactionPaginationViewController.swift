//
//  TransactionPaginationViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 9/9/20.
//  Copyright © 2020 Frollo. All rights reserved.
//

import FrolloSDK
import UIKit
import CoreData

class TransactionPaginationViewController: UIViewController {
    
    @IBOutlet var afterLabel: UILabel!
    @IBOutlet var beforeLabel: UILabel!
    @IBOutlet var cacheCountLabel: UILabel!
    @IBOutlet var responseCountLabel: UILabel!
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var afterValueLabel: UILabel!
    @IBOutlet var beforeValueLabel: UILabel!
    
    var transactionFilter: TransactionFilter!
    var pagecount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionFilter = TransactionFilter(size: 300)
        printData()
    }
    
    func printData(total: String? = nil, before: String? = nil, after: String? = nil, beforeValue: String? = nil, afterValue: String? = nil) {
        
        self.cacheCountLabel.text = "Cached count: \(Frollo.shared.aggregation.transactions(context: Frollo.shared.database.viewContext, transactionFilter: transactionFilter)?.count ?? 0)"
        self.responseCountLabel.text = "Total count from API: " + (total ?? "N/A")
        self.afterLabel.text = "After: \(after ?? "N/A")"
        self.beforeLabel.text = "Before: \(before ?? "N/A")"
        self.beforeValueLabel.text = "Before date and ID: \(beforeValue ?? "N/A")"
        self.afterValueLabel.text = "After date and ID : \(afterValue ?? "N/A")"
        
        if transactionFilter.filterPredicates.count > 0 {
            var filterPredicate = "Filter: "
            for predicate in self.transactionFilter.filterPredicates {
                filterPredicate.append(predicate.predicateFormat + " AND ")
            }
            self.filterLabel.text = filterPredicate
        } else {
            self.filterLabel.text = "No Filters"
        }
        
        loadingLabel.text = "Page Count: \(pagecount)"
    }
    
    @IBAction func fetchNectTransactions(_ sender: Any) {
        
        loadingLabel.text = "Loading..."
        
        Frollo.shared.aggregation.refreshTransactions(transactionFilter: transactionFilter) { result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
            case .success(let before, let after, let total, let beforeID, let afterID, let beforeDate, let afterDate):
                    self.transactionFilter.after = after
                    self.pagecount += 1
                    self.printData(total: "\(total!)", before: before, after: after, beforeValue: "\(beforeDate) \(beforeID)", afterValue: "\(afterDate) \(afterID)")
                
                    if after == nil {
                        self.pagecount = 0
                    }
            }
        }
    }
}
