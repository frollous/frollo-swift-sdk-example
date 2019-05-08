//
//  DateFormatterExtensions.swift
//  FrolloSDK Example
//
//  Created by Maher Santina on 8/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let `default`: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
}
