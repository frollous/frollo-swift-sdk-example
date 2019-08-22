//
//  StartupViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 18/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

class StartupViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    public weak var flowManager: FlowManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimating()
        
        SetupManager.shared.setup {
            DispatchQueue.main.async {
                self.completeStartup()
            }
        }
    }
    

    // MARK: - Navigation
    
    private func completeStartup() {
        spinner.stopAnimating()
        
        if Frollo.shared.authentication.loggedIn {
            flowManager?.showMainSplitViewController()
            
            UIApplication.shared.registerForRemoteNotifications()
            
            DispatchQueue.main.async {
                Frollo.shared.refreshData()
            }
        } else {
            flowManager?.showLoginViewController()
        }
    }

}
