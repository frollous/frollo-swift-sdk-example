//
//  TransactionCell.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 26/10/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tagsCollectionView: TagsCollectionView!
}
