//
//  FlowManager.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 23/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import UIKit

class FlowManager: UISplitViewControllerDelegate {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showMainSplitViewController() {
        let splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplitViewController") as! UISplitViewController
        //splitViewController.flowManager = self
        splitViewController.delegate = self
        window.rootViewController = splitViewController
    }
    
    func showLoginViewController() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.flowManager = self
        window.rootViewController = loginViewController
    }
    
    // MARK: - Delegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
