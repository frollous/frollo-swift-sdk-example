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
    var grouping: ReportGrouping
}

extension ReportItem: ReportItemDisplayable {
    var reportItemDateText: String? {
        return date
    }
    
    var reportItemAmountText: String? {
        return "\(amount)"
    }
    
    var reportItemGroupNameText: String? {
        return grouping.rawValue
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

extension ReportResponse {
    var reportItems: [ReportItemDisplayable] {
        return groupReports.map{ _ in ReportItem(date: date, amount: value, grouping: T.grouping) }
    }
}

struct ReportForm<T: Reportable> {
    var filtering: TransactionReportFilter
    var grouping: ReportGrouping
    var period: Reports.Period
    
    
    func fetch(completion: @escaping RequestCompletion<[ReportItemDisplayable]>) {
        
        func getCompletion<T>(result: ReportsResponse<T>) -> ((RequestCompletion<[ReportItemDisplayable]>) -> Void) {
            return {
                
            }
        }
        
        let now = Date()
        let oneYearBack = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        Frollo.shared.reports.fetchTransactionReports(filtering: filtering, grouping: grouping, period: period, from: oneYearBack, to: now, completion: {
        result in
            switch result {
            case .success(let reports):
                let items = reports.flatMap{ $0.reportItems }
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}

let a = ReportForm(filtering: .category(id: nil), grouping: TransactionCategoryGroupReport.self, period: .weekly)
