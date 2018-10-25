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

        DataManager.shared.frolloSDK.setup { (error) in
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
        
        if DataManager.shared.frolloSDK.authentication.loggedIn {
            flowManager?.showMainSplitViewController()
            
            DispatchQueue.main.async {
                DataManager.shared.frolloSDK.refreshData()
            }
        } else {
            flowManager?.showLoginViewController()
        }
    }

}
