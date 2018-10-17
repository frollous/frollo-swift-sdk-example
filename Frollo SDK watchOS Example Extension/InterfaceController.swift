//
//  InterfaceController.swift
//  Frollo SDK watchOS Example Extension
//
//  Created by Nick Dawson on 17/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import WatchKit
import Foundation

import FrolloSDK

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
