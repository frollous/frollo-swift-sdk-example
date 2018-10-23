//
//  FlowManager.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 23/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import UIKit

class FlowManager {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showMainSplitViewController() {
        let splitViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplitViewController")
        //splitViewController.flowManager = self
        window.rootViewController = splitViewController
    }
    
    func showLoginViewController() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginViewController.flowManager = self
        window.rootViewController = loginViewController
    }
    
}
