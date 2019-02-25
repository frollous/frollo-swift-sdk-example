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

        let clientID = "x"
        let clientSecret = "y"
        let redirectURI = "frollo://auth"
        let authorizationURL = URL(string: "https://id-sandbox.frollo.us/oauth/authorization")!
        let tokenURL = URL(string: "https://id-sandbox.frollo.us/oauth/token")!
        let serverURL = URL(string: "https://api-sandbox.frollo.us/api/v2/")!
        
        let config = FrolloSDKConfiguration(clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI, authorizationEndpoint: authorizationURL, tokenEndpoint: tokenURL, serverEndpoint: serverURL)
        
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
