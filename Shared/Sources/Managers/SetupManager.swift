//
//  SetupManager.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 5/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation

import FrolloSDK

class SetupManager {
    
    enum Host: String {
        case frolloSandbox
        case frolloStaging
        case frolloProduction
        case pioneerSandbox
        case pioneerStaging
        case pioneerProduction
        case voltSandbox
        case voltStaging
        case voltProduction
    }
    
    static let shared = SetupManager()
    
    let currentHostKey = "SDKExampleCurrentHostConfig"
    let selectedHostKey = "SDKExampleSelectedHostConfig"
    let redirectURL = URL(string: "frollo-sdk-example://authorize")!
    let useV1AuthKey = "SDKExampleUseV1Authentication"
    
    var authentication: CustomV1Authentication?
    var currentHost: Host = .frolloSandbox
    var selectedHost: Host = .frolloSandbox
    var useV1Auth = false
    
    internal func setup(completion: @escaping () -> Void) {
        reloadHostPreferences()
        
        var config = hostConfig(host: selectedHost)
        config.logLevel = .debug
        
        if useV1Auth {
            let baseV1URL = baseURL(host: selectedHost).appendingPathComponent("v1/")
            let baseV2URL = baseURL(host: selectedHost).appendingPathComponent("v2/")
            let auth = CustomV1Authentication(baseURL: baseV1URL)
            authentication = auth
            
            config = FrolloSDKConfiguration(authenticationType: .custom(authentication: auth),
                                            serverEndpoint: baseV2URL)
        }
        
        FrolloSDK.shared.setup(configuration: config) { (result) in
            switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success:
                    DispatchQueue.main.async {
                        self.completeSetup(completion: completion)
                }
            }
        }
    }
    
    internal func completeSetup(completion: @escaping () -> Void) {
        saveHostPreferences()
        
        if selectedHost != currentHost {
            FrolloSDK.shared.reset { (result) in
                abort()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { (notification) in
            self.reloadHostPreferences()
            
            if self.currentHost != self.selectedHost, FrolloSDK.shared.authentication.loggedIn {
                self.saveHostPreferences()
                
                FrolloSDK.shared.reset { (result) in
                    abort()
                }
            }
        }
        
        completion()
    }
    
    // MARK: - Host Preferences
    
    private func reloadHostPreferences() {
        useV1Auth = UserDefaults.standard.bool(forKey: useV1AuthKey)
        
        // Check the existing host
        if let selectedHostString = UserDefaults.standard.string(forKey: selectedHostKey), let host = Host(rawValue: selectedHostString) {
            selectedHost = host
        }
        
        // Check the selected host
        if let currentHostString = UserDefaults.standard.string(forKey: currentHostKey), let host = Host(rawValue: currentHostString) {
            currentHost = host
        }
    }
    
    private func saveHostPreferences() {
        UserDefaults.standard.set(useV1Auth, forKey: useV1AuthKey)
        UserDefaults.standard.set(selectedHost.rawValue, forKey: selectedHostKey)
        UserDefaults.standard.set(selectedHost.rawValue, forKey: currentHostKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Config
    
    private func baseURL(host: Host) -> URL {
        switch host {
            case .frolloSandbox:
                return URL(string: "https://api-sandbox.frollo.us/api/")!
            case .frolloStaging:
                return URL(string: "https://api-staging.frollo.us/api/")!
            case .frolloProduction:
                return URL(string: "https://api.frollo.us/api/v1/")!
            case .voltSandbox:
                return URL(string: "https://volt-sandbox.frollo.us/api/")!
            default:
                return URL(string: "https://api-sandbox.frollo.us/api/")!
        }
    }
    
    private func hostConfig(host: Host) -> FrolloSDKConfiguration {
        switch host {
            case .frolloSandbox:
                return FrolloSDKConfiguration(authenticationType: .oAuth2(clientID: "f97faef0bdef6882a5cbabaf4afc2f3bc8612f725a8434f9daebf2ad3c259cc1",
                                                                          redirectURL: redirectURL,
                                                                          authorizationEndpoint: URL(string: "https://id-sandbox.frollo.us/oauth/authorize")!,
                                                                          tokenEndpoint: URL(string: "https://id-sandbox.frollo.us/oauth/token")!),
                                              serverEndpoint: URL(string: "https://api-sandbox.frollo.us/api/v2/")!)
            case .voltSandbox:
                return FrolloSDKConfiguration(authenticationType: .oAuth2(clientID: "PzlborkOwZf42SJ2b6Fdj6JTi9lcqiNi",
                                                                          redirectURL: redirectURL,
                                                                          authorizationEndpoint: URL(string: "https://frollo-test.au.auth0.com/authorize")!,
                                                                          tokenEndpoint: URL(string: "https://frollo-test.au.auth0.com/oauth/token")!),
                                              serverEndpoint: URL(string: "https://volt-sandbox.frollo.us/api/v2/")!)
            default:
                // Return frollo sandbox for now
                return FrolloSDKConfiguration(authenticationType: .oAuth2(clientID: "f97faef0bdef6882a5cbabaf4afc2f3bc8612f725a8434f9daebf2ad3c259cc1",
                                                                          redirectURL: redirectURL,
                                                                          authorizationEndpoint: URL(string: "https://id-sandbox.frollo.us/oauth/authorize")!,
                                                                          tokenEndpoint: URL(string: "https://id-sandbox.frollo.us/oauth/token")!),
                                              serverEndpoint: URL(string: "https://api-sandbox.frollo.us/api/v2/")!)
        }
    }
    
}
