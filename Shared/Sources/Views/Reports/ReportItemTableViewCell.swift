//
//  ReportItemTableViewCell.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 17/12/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit



class ReportItemTableViewCell: UITableViewCell {
    
    var data: ReportItemDisplayable? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var groupLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateView() {
        dateLabel?.text = data?.reportItemDateText
        amountLabel?.text = data?.reportItemAmountText
        groupLabel?.text = data?.reportItemGroupNameText
    }

}
