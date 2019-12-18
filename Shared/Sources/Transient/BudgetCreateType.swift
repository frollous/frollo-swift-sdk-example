//
//  BudgetCreateType.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 9/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//
import FrolloSDK

enum BudgetCreateType {
    case budgetCategory(budgetCategory: BudgetCategory)
    case category(categoryID: Int64)
    case merchant(merchantID: Int64)
}

extension BudgetCreateType : CaseIterable {
    static var allCases: [BudgetCreateType] {
        return [.budgetCategory(budgetCategory: .living), .category(categoryID: 0), .merchant(merchantID: 0)]
    }
}

extension BudgetCreateType: RawRepresentable {
    
    init?(rawValue: String) {
        return nil
    }
    
    typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .budgetCategory:   return "Budget Category"
        case .category:   return "Category"
        case .merchant: return "Merchant"
        }
    }
}
