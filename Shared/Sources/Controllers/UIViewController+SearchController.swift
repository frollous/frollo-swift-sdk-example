//
//  UIViewController+SearchController.swift
//  FrolloSDK Example
//
//  Created by Maher Santina on 8/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit

extension UISearchResultsUpdating where Self: UIViewController, Self: UISearchBarDelegate {
    func defaultSearchController(placeHolder: String? = nil) -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = placeHolder
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        definesPresentationContext = true
        return searchController
    }
}
