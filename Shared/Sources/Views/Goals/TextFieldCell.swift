//
//  TextFieldCell.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 26/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
