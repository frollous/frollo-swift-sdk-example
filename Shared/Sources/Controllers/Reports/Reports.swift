//
//  Reports.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 10/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import FrolloSDK

/// Represents a report item in a group report
struct ReportItem {
    var date: String
    var amount: Decimal
    var name: String
}

/// Objects conforming to this can be displayed in a report items list
protocol ReportItemDisplayable {
    var reportItemDateText: String? { get }
    var reportItemAmountText: String? { get }
    var reportItemGroupNameText: String? { get }
}

extension ReportItem: ReportItemDisplayable {
    var reportItemDateText: String? {
        return date
    }
    
    var reportItemAmountText: String? {
        return "\(amount)"
    }
    
    var reportItemGroupNameText: String? {
        return name
    }
}

extension ReportResponse {
    
    /// The report items that will be displayed in the report items list
    var reportItems: [ReportItemDisplayable] {
        return groupReports.map{ ReportItem(date: date, amount: $0.value, name: $0.name) }
    }
}

/// Represents a way to handle form input
protocol ReportFormRepresentable {
    var filtering: TransactionReportFilter { get }
    var grouping: ReportGrouping { get }
    var period: Reports.Period { get }
}

extension ReportFormRepresentable {
    
    /// Will fetch results depending on the form input data
    func fetch(completion: @escaping (Result<[ReportItemDisplayable], Error>) -> Void) {
        
        /// Will map the results from the fetch responses into a completion with displayable report items
        func mapDisplayableItemsFromFetchCompletion<T: Reportable>(result: Result<[ReportResponse<T>], Error>) {
            switch result {
            case .success(let response):
                completion(.success(response.flatMap{ $0.reportItems }))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        let now = Date()
        let oneYearBack = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let period = Reports.Period.monthly
        switch grouping {
        case .budgetCategory:
            Frollo.shared.reports.fetchTransactionReports(filtering: filtering, grouping: BudgetCategoryGroupReport.self, period: period, from: oneYearBack, to: now) {
                result in
                mapDisplayableItemsFromFetchCompletion(result: result)
            }
        case .merchant:
            Frollo.shared.reports.fetchTransactionReports(filtering: filtering, grouping: MerchantGroupReport.self, period: period, from: oneYearBack, to: now) {
                result in
                mapDisplayableItemsFromFetchCompletion(result: result)
            }
        case .transactionCategory:
            Frollo.shared.reports.fetchTransactionReports(filtering: filtering, grouping: TransactionCategoryGroupReport.self, period: period, from: oneYearBack, to: now) {
                result in
                mapDisplayableItemsFromFetchCompletion(result: result)
            }
        case .tag:
            Frollo.shared.reports.fetchTransactionReports(filtering: filtering, grouping: TagGroupReport.self, period: period, from: oneYearBack, to: now) {
                result in
                mapDisplayableItemsFromFetchCompletion(result: result)
            }
        }
    }
}
