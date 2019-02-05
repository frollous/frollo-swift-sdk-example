//
//  AddProviderLoginFieldView.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

class AddProviderLoginFieldView: UIView {

    @IBOutlet var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        layer.borderColor = #colorLiteral(red: 0.7959910631, green: 0.7961286902, blue: 0.7959824204, alpha: 1).cgColor
        layer.borderWidth = 1.0
    }
    

}
