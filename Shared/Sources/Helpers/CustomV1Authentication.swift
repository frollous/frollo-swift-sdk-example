//
//  CustomV1Authentication.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 20/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit

import FrolloSDK

extension UIDevice {
    
    var platform: String {
        get {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
    
}

class CustomV1Authentication: Authentication {
    
    var loggedIn = false
    
    var delegate: AuthenticationDelegate?
    
    private let baseURL: URL
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func loginUser(email: String, password: String, completion: @escaping FrolloSDKCompletionHandler) {
        let loginURL = URL(string: "user/login", relativeTo: baseURL)!
        
        let payload = ["auth_type": "email",
                       "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
                       "device_name": UIDevice.current.name,
                       "device_type": UIDevice.current.platform,
                       "email": email,
                       "password": password]
        
        let json = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        
        var request = URLRequest(url: loginURL)
        request.httpBody = json
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // Custom user agent
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let userAgent = String(format: "%@|V%@|B%@|iOS%@|API%@", arguments: [Bundle.main.bundleIdentifier!, appVersion, appBuild, UIDevice.current.systemVersion, "1.19"])
        
        request.setValue(userAgent, forHTTPHeaderField: "user-agent")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let responseError = error {
                    completion(.failure(responseError))
                } else {
                    if let responseData = data, let responseJSON = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let accessToken = responseJSON["access_token"] as? String {
                            self.loggedIn = true
                            
                            self.delegate?.saveAccessTokens(accessToken: accessToken, expiry: Date().addingTimeInterval(600))
                            
                            completion(.success)
                        } else {
                            let error = NSError(domain: "CustomV1AuthDomain", code: -2, userInfo: [NSLocalizedDescriptionKey: "Data Did Not contain an access token"])
                            
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "CustomV1AuthDomain", code: -2, userInfo: [NSLocalizedDescriptionKey: "Data Invalid Format"])
                        
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    func refreshTokens(completion: FrolloSDKCompletionHandler?) {
        // Only one access token is retrieved - reset if we try to renew the token
        reset()
        
        completion?(.success)
    }
    
    func resumeAuthentication(url: URL) -> Bool {
        // Unused
        return false
    }
    
    func reset() {
        loggedIn = false
    }
    
}
