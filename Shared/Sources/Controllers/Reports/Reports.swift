//
//  Reports.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 10/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import FrolloSDK

struct ReportItem {
    var date: String
    var amount: Decimal
    var name: String
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

protocol ReportItemDisplayable {
    var reportItemDateText: String? { get }
    var reportItemAmountText: String? { get }
    var reportItemGroupNameText: String? { get }
}

extension ReportItemDisplayable where Self: Reportable {
    var reportItemGroupNameText: String? {
        return Self.grouping.rawValue
    }
}

protocol ReportItemsProvider {
    var reportItems: [ReportItemDisplayable] { get }
}

extension ReportResponse: ReportItemsProvider {
    var reportItems: [ReportItemDisplayable] {
        return groupReports.map{ ReportItem(date: date, amount: $0.value, name: $0.name) }
    }
}

protocol ReportFormRepresentable {
    var filtering: TransactionReportFilter { get }
    var grouping: ReportGrouping { get }
    var period: Reports.Period { get }
}

extension ReportFormRepresentable {
    
    func fetch(completion: @escaping RequestCompletion<[ReportItemDisplayable]>) {
        
        /// Will map the results from the fetch responses into a completion with displayable report items
        func mapDisplayableItemsFromFetchCompletion<T: Reportable>(result: Result<ReportsResponse<T>, Error>) {
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
