//
//  SurveyAnswerTableCell.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 18/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit
import FrolloSDK

class SurveyAnswerTableCell: UITableViewCell {
    
    @IBOutlet weak var answerTitleLabel: UILabel!
    @IBOutlet weak var answerImage: UIImageView!
    @IBOutlet weak var answerInputText: UITextField!
    
    var answer : Survey.Question.Answer!{
        didSet{
            answerTitleLabel.text = answer.displayText ?? ""
            answerImage.isHidden = !answer.selected
            if(answer.answerType == .normalSelection){
                answerInputText.isHidden = true
            }else{
                answerInputText.isHidden = false
                answerInputText.addTarget(self, action: #selector(textFieldEditingDidChange(_:)), for: UIControl.Event.editingChanged)
            }
        }
    }
    
    @objc func textFieldEditingDidChange(_ sender: UITextField){
        answer.value = sender.text ?? ""
    }
    
}
