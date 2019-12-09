//
//  BaseViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 5/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    internal var progressView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showError(title: String? = "Error", details: String) {
        let alertController = UIAlertController(title: title, message: details, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true)
    }
    
    func showProgress() {
        
        if progressView == nil {
            progressView = UIView()
            progressView.frame = view.bounds
            progressView.backgroundColor = UIColor.black
            progressView.alpha = 0.7
            let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicator.startAnimating()
            activityIndicator.frame = progressView.bounds
            activityIndicator.center = progressView.center
            activityIndicator.color = .white
            progressView.addSubview(activityIndicator)
        }
        
        view.addSubview(progressView)
        
    }
    
    func hideProgress() {
        if progressView != nil {
            progressView.removeFromSuperview()
        }
    }
    
}
