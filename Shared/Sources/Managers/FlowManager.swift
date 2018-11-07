//
//  FlowManager.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 23/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import UIKit

import FrolloSDK

class FlowManager: UISplitViewControllerDelegate {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        
        NotificationCenter.default.addObserver(forName: FrolloSDK.authenticationChangedNotification, object: nil, queue: .main) { (notification) in
            if let status = notification.userInfo?[FrolloSDK.authenticationStatusKey] as? FrolloSDK.FrolloSDKAuthenticationStatus, status == .loggedOut {
                self.showLoginViewController()
            }
        }
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
