//
//  DataManager.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 18/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation

import FrolloSDK

class DataManager {
    
    public static let shared = DataManager()
    
    public var frolloSDK: FrolloSDK
    
    init() {
        let serverURL = URL(string: "https://api-sandbox.frollo.us/api/v1/")!
        
        frolloSDK = FrolloSDK(serverURL: serverURL)
    }
    
}
