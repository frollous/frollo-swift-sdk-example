//
//  TransactionReportFormViewModel.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 17/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import FrolloSDK

extension Merchant: SelectionDisplayable {
    var title: String? {
        return name
    }
}

extension BudgetCategory: SelectionDisplayable {
    var title: String? {
        return rawValue
    }
}

extension TransactionCategory: SelectionDisplayable {
    var title: String? {
        return name
    }
}

extension Tag: SelectionDisplayable {
    var title: String? {
        return name
    }
}

extension Reports.Period: SelectionDisplayable {
    var title: String? {
        return rawValue
    }
}

extension TransactionReportFilter: SelectionDisplayable {
    var title: String? {
        return entity
    }
}

enum FilterEntity: String, CaseIterable {
    case budgetCategory
    case merchant
    case category
    case tag
}

extension FilterEntity: SelectionDisplayable {
    var title: String? {
        return rawValue
    }
}

extension ReportGrouping: SelectionDisplayable {
    var title: String? {
        return rawValue
    }
}

class TransactionReportFormViewModel {
    struct State {
        var filterSelectedIndex: Int?
        var filterBySelectedIndex: Int?
        var groupingSelectedIndex: Int?
        var periodSelectedIndex: Int?
        
        var currentFilterEntity: FilterEntity? {
            guard let index = filterSelectedIndex else { return nil }
            return FilterEntity.allCases[index]
        }
        
        var currentGrouping: ReportGrouping? {
            guard let index = filterBySelectedIndex else { return nil }
            return ReportGrouping.allCases[index]
        }
        
        var currentPeriod: Reports.Period? {
            guard let index = periodSelectedIndex else { return nil }
            return Reports.Period.allCases[index]
        }
        
        
        mutating func setIndex(_ index: Int, forField field: TransactionReportFormViewController.FormField) {
            switch field {
            case .filter:
                filterSelectedIndex = index
            case .filterBy:
                filterBySelectedIndex = index
            case .grouping:
                groupingSelectedIndex = index
            case .period:
                periodSelectedIndex = index
            }
        }
    }
    
    var state: State = State()
    
    var merchants: [Merchant] {
        return Frollo.shared.aggregation.merchants(context: Frollo.shared.database.viewContext) ?? []
    }
    
    var budgetCategories: [BudgetCategory] {
        return BudgetCategory.allCases
    }
    
    var periods: [Reports.Period] {
        return Reports.Period.allCases
    }
    
    var categories: [TransactionCategory] {
        return Frollo.shared.aggregation.transactionCategories(context: Frollo.shared.database.viewContext) ?? []
    }
    
    var tags: [Tag] {
        return Frollo.shared.aggregation.transactionUserTags(context: Frollo.shared.database.viewContext) ?? []
    }
    
    var groupings: [ReportGrouping] {
        return ReportGrouping.allCases
    }
    
}

extension TransactionReportFormViewModel: TransactionReportFormViewControllerDataSource {
    var transactionReportFormFilter: String? {
        return state.currentFilterEntity?.rawValue ?? "Select"
    }
    
    var transactionReportFormFilterBy: String? {
        guard let index = state.filterBySelectedIndex else { return "Select" }
        return selectionItems(forType: .filterBy)[index].title
    }
    
    var transactionReportFormGrouping: String? {
        return state.currentGrouping?.rawValue ?? "Select"
    }
    
    var transactionReportFormPeriod: String? {
        return state.currentPeriod?.rawValue ?? "Select"
    }
    
    func selectionItems(forType: TransactionReportFormViewController.FormField) -> [SelectionDisplayable] {
        switch forType {
        case .filter:
            return FilterEntity.allCases
        case .filterBy:
            switch state.currentFilterEntity {
            case .budgetCategory:
                return budgetCategories
            case .category:
                return categories
            case .merchant:
                return merchants
            case .tag:
                return tags
            case .none:
                return []
            }
        case .grouping:
            return groupings
        case .period:
            return periods
        }
    }
}

extension TransactionReportFormViewModel: TransactionReportFormViewControllerDelegate {
    
    func didSelectIndex(index: Int, forField field: TransactionReportFormViewController.FormField) {
        state.setIndex(index, forField: field)
    }
}
