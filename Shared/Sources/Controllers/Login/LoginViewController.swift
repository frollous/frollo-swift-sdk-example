//
//  LoginViewController.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 18/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UserNotifications
import UIKit

import FrolloSDK

class LoginViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var webLoginButton: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordContainerView: UIView!
    @IBOutlet var usernameContainerView: UIView!
    
    public weak var flowManager: FlowManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Login"
        
        themeTextFieldContainer(usernameContainerView)
        themeTextFieldContainer(passwordContainerView)
    }
    
    private func themeTextFieldContainer(_ textFieldView: UIView) {
        textFieldView.layer.borderColor = UIColor.darkGray.cgColor
        textFieldView.layer.borderWidth = 1.0
    }
    

    // MARK: - Interaction
    
    @IBAction func loginPress(sender: UIButton) {
        guard let email = usernameTextField.text,
            let password = passwordTextField.text
            else {
            return
        }
        
        loginButton.isHidden = true
        webLoginButton.isHidden = true
        spinner.startAnimating()
        
        FrolloSDK.shared.authentication.loginUser(email: email, password: password) { (result) in
            self.loginButton.isHidden = false
            self.webLoginButton.isHidden = false
            self.spinner.stopAnimating()
            
            switch result {
                case .failure(let error):
                    let alertController = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .cancel)
                    alertController.addAction(dismissAction)
                    
                    self.present(alertController, animated: true)
                case .success:
                    self.completeLogin()
            }
        }
    }
    
    @IBAction func webLoginPress(sender: UIButton) {
        loginButton.isHidden = true
        webLoginButton.isHidden = true
        spinner.startAnimating()
        
        FrolloSDK.shared.authentication.loginUserUsingWeb(presenting: self) { (result) in
            self.loginButton.isHidden = false
            self.webLoginButton.isHidden = false
            self.spinner.stopAnimating()
            
            switch result {
                case .failure(let error):
                    let alertController = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .cancel)
                    alertController.addAction(dismissAction)
                    
                    self.present(alertController, animated: true)
                case .success:
                    self.completeLogin()
            }
        }
    }
    
    // MARK: - Push Notifications
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: - Login
    
    private func completeLogin() {
        flowManager?.showMainSplitViewController()
        
        registerForPushNotifications()
        
        DispatchQueue.main.async {
            FrolloSDK.shared.refreshData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
