//
//  GoalListCell.swift
//  FrolloSDK Example
//
//  Created by Nick Dawson on 30/7/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit

class GoalListCell: UITableViewCell {
    
    @IBOutlet var currentAmountLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var targetLabel: UILabel!
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
