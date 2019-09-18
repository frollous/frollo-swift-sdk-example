//
//  AmountCell.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 29/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class AmountCell: UITableViewCell {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
