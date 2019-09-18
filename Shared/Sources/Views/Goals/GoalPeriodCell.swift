//
//  GoalPeriodCell.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 30/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class GoalPeriodCell: UITableViewCell {
    
    @IBOutlet var currentAmountLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var requiredAmountLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var targetAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
