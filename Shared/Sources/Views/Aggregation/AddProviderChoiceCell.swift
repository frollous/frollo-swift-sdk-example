//
//  AddProviderChoiceCell.swift
//  FrolloSDK iOS Example
//
//  Created by Nick Dawson on 1/11/18.
//  Copyright © 2018 Frollo. All rights reserved.
//

import UIKit

import FrolloSDK

protocol AddProviderChoiceCellDelegate: class {
    
    func cellChoiceChanged(cell: AddProviderChoiceCell, choiceIndex: Int)
    func cellChoiceFieldValueChanged(sender: AddProviderChoiceCell, fieldIndex: Int, updatedText: String?)
    
}

class AddProviderChoiceCell: UITableViewCell, UITextFieldDelegate, AddProviderChoiceViewDelegate {
    
    @IBOutlet var choiceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var choiceStackView: UIStackView!
    @IBOutlet var fieldStackView: UIStackView!
    
    public weak var delegate: AddProviderChoiceCellDelegate?
    
    private var maxLengths = [Int]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    public func updateChoices(_ cell: ProviderLoginFormViewModel.Cell) {
        for view in choiceStackView.arrangedSubviews {
            choiceStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        var index = 0
        
        for row in cell.rows {
            let choiceView = UINib(nibName: "AddProviderChoiceView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AddProviderChoiceView
            choiceView.translatesAutoresizingMaskIntoConstraints = false
            choiceView.delegate = self
            choiceView.nameLabel.text = row.label
            choiceView.index = index
            
            let selected = cell.selectedRowID == row.id
            choiceView.selected = selected
            
            choiceStackView.addArrangedSubview(choiceView)
            
            if selected {
                updateSelectedChoice(row, index: index)
            }
            
            index += 1
        }
    }
    
    public func updateSelectedChoice(_ choice: ProviderLoginForm.Row, index: Int) {
        titleLabel.text = choice.label
        
        updateLoginFields(fields: choice.field)
    }
    
    private func updateLoginFields(fields: [ProviderLoginForm.Field]) {
        for subView in fieldStackView.arrangedSubviews {
            fieldStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        
        maxLengths = [Int]()
        
        var tag = 1
        
        for field in fields {
            let length: CGFloat
            
            if let max = field.maxLength {
                length = CGFloat(max) * 13
                
                maxLengths.append(max)
            } else {
                length = fieldStackView.frame.width
                
                maxLengths.append(-1)
            }
            
            let loginFieldView = UINib(nibName: "AddProviderLoginFieldView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! AddProviderLoginFieldView
            loginFieldView.textField.delegate = self
            loginFieldView.textField.tag = tag
            loginFieldView.textField.text = field.value
            loginFieldView.addConstraint(NSLayoutConstraint(item: loginFieldView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: length))
            loginFieldView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            
            fieldStackView.addArrangedSubview(loginFieldView)
            
            tag += 1
        }
        
        // Padding view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .horizontal)
        fieldStackView.addArrangedSubview(view)
    }
    
    // MARK: - Delegate
    
    func optionSelected(_ option: AddProviderChoiceView) {
        delegate?.cellChoiceChanged(cell: self, choiceIndex: option.index)
    }
    
    // MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text as NSString?
        let proposedString = currentString?.replacingCharacters(in: range, with: string)
        
        let fieldIndex = textField.tag - 1
        
        if let checkString = proposedString {
            let maxChars = maxLengths[fieldIndex]
            
            if maxChars > 0 && checkString.count > maxChars {
                return false
            }
        }
        
        delegate?.cellChoiceFieldValueChanged(sender: self, fieldIndex: fieldIndex, updatedText: proposedString)
        
        return true
    }

}
