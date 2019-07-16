//
//  UserTagCell.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 8/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK

protocol TagDisplayable {
    var tagName: String? { get }
    var tagCount: String? { get }
    var tagLastUsedAt: String? { get }
    var tagCreatedAt: String? { get }
}

extension Tag: TagDisplayable {
    var tagName: String? {
        return name
    }
    
    var tagCount: String? {
        guard count >= 0 else {
            return nil
        }
        return String(count)
    }
    
    var tagLastUsedAt: String? {
        guard let lastUsedAt = lastUsedAt else {
            return nil
        }
        return "Last Used At: \(DateFormatter.default.string(from: lastUsedAt))"
    }
    
    var tagCreatedAt: String? {
        guard let createdAt = createdAt else {
            return nil
        }
        return "Created At: \(DateFormatter.default.string(from: createdAt))"
    }
}

class UserTagCell: UITableViewCell {

    var data: TagDisplayable? {
        didSet {
            updateView()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var lastUsedAtLabel: UILabel!
    @IBOutlet weak var lastUsedAtView: UIView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var createdAtView: UIView!
    
    
    private func updateView() {
        guard let data = data else {
            updateEmptyView()
            return
        }
        nameLabel.text = data.tagName
        countLabel.text = data.tagCount
        
        
        lastUsedAtLabel.text = data.tagLastUsedAt
        if data.tagLastUsedAt != nil {
            lastUsedAtView.isHidden = false
        }
        else {
            lastUsedAtView.isHidden = true
        }
        
        createdAtLabel.text = data.tagCreatedAt
        if data.tagCreatedAt != nil {
            createdAtView.isHidden = false
        }
        else {
            createdAtView.isHidden = true
        }
    }
    
    private func updateEmptyView() {
        nameLabel.text = nil
        countLabel.text = nil
        lastUsedAtLabel.text = nil
        createdAtLabel.text = nil
    }
    
}
