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

        let serverURL = URL(string: "https://api-sandbox.frollo.us/api/v2/")!
        
        FrolloSDK.shared.setup(serverURL: serverURL, logLevel: .debug, publicKeyPinningEnabled: false) { (error) in 
            if let setupError = error {
                fatalError(setupError.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.completeStartup()
                }
            }
        }
    }
    

    // MARK: - Navigation
    
    private func completeStartup() {
        spinner.stopAnimating()
        
        if FrolloSDK.shared.authentication.loggedIn {
            flowManager?.showMainSplitViewController()
            
            UIApplication.shared.registerForRemoteNotifications()
            
            DispatchQueue.main.async {
                FrolloSDK.shared.refreshData()
            }
        } else {
            flowManager?.showLoginViewController()
        }
    }

}
