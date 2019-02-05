//
//  BillCell.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 10/1/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class BillCell: UITableViewCell {
    
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
