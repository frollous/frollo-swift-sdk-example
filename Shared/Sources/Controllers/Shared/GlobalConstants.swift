//
//  GlobalConstants.swift
//  FrolloSDK Example
//
//  Created by Dipesh Dhakal on 18/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

let frolloDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

let frolloCurrencyFormatter: NumberFormatter = {
       let numberFormatter = NumberFormatter()
       numberFormatter.locale = Locale.autoupdatingCurrent
       numberFormatter.numberStyle = .currency
       numberFormatter.maximumFractionDigits = 0
       return numberFormatter
   }()
