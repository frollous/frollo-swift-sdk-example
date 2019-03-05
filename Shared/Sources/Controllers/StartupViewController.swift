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

        let clientID = "PzlborkOwZf42SJ2b6Fdj6JTi9lcqiNi"
        let redirectURL = URL(string: "frollo-sdk-example://authorize")!
        let authorizationURL = URL(string: "https://frollo-test.au.auth0.com/authorize")!
        let tokenURL = URL(string: "https://frollo-test.au.auth0.com/oauth/token")!
        let serverURL = URL(string: "https://volt-sandbox.frollo.us/api/v2/")!
        
//        let clientID = "f97faef0bdef6882a5cbabaf4afc2f3bc8612f725a8434f9daebf2ad3c259cc1"
//        let redirectURL = URL(string: "frollo-sdk-example://authorize")!
//        let authorizationURL = URL(string: "https://id-sandbox.frollo.us/oauth/authorize")!
//        let tokenURL = URL(string: "https://id-sandbox.frollo.us/oauth/token")!
//        let serverURL = URL(string: "https://api-sandbox.frollo.us/api/v2/")!
        
        let config = FrolloSDKConfiguration(clientID: clientID, redirectURL: redirectURL, authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL, serverEndpoint: serverURL)
        
        FrolloSDK.shared.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success:
                    DispatchQueue.main.async {
                        self.completeStartup()
                    }
            }
        }
        
        SetupManager.shared.setup {
            DispatchQueue.main.async {
                self.completeStartup()
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
