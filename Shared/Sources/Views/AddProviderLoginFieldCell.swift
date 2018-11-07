//
//  AddProviderLoginFieldCell.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

class AddProviderLoginFieldCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet var textFieldContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textFieldContainerView.layer.borderColor = #colorLiteral(red: 0.7959910631, green: 0.7961286902, blue: 0.7959824204, alpha: 1).cgColor
        textFieldContainerView.layer.borderWidth = 1.0
    }

}
