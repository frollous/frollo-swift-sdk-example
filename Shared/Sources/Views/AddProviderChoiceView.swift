//
//  AddProviderChoiceView.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import Foundation
import UIKit

protocol AddProviderChoiceViewDelegate: class {
    
    func optionSelected(_ option: AddProviderChoiceView)
    
}

class AddProviderChoiceView: UIView {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tickContainerView: UIView!
    
    public var index: Int = -1
    public var selected = false {
        didSet {
            tickContainerView.backgroundColor = selected ? UIColor.green : UIColor.lightGray
        }
    }
    
    public weak var delegate: AddProviderChoiceViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        tickContainerView.layer.cornerRadius = tickContainerView.frame.width / 2
        tickContainerView.layer.masksToBounds = true
    }
    
    @IBAction func optionTapped(sender: UIButton) {
        selected = true
        
        delegate?.optionSelected(self)
    }

    
}
