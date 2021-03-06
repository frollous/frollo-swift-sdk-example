//
//  SurveySliderViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 15/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit
import FrolloSDK

class SurveySliderViewController: UIViewController {
    
    @IBOutlet weak var answerDisplayTextLabel: UILabel!
    @IBOutlet weak var answerIconImageView: UIImageView!
    @IBOutlet weak var answerDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var answerSlider: FrolloSlider!
    
    var surveyQuestion : Survey.Question!
    var questionIndex : Int!
    weak var delegate : SurveyQuestionCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = surveyQuestion.title
        displayLabel.text = surveyQuestion.displayText ?? ""
        answerSlider.delegate = self
        
        setDynamicSlider()
    }
    
    // set default selected value in slider and text
    func setDynamicSlider(){
        answerSlider.minValue = 0
        answerSlider.maxValue = surveyQuestion.answers.count - 1
        var values = [String]()
        var defaultValue = 0
        for (i,answer) in surveyQuestion.answers.enumerated(){
            values.append(answer.value)
            if(answer.selected){
                defaultValue = i
            }
        }
        answerSlider.values = values
        answerSlider.selectedValue = defaultValue
        answerDescriptionLabel.text = surveyQuestion.answers[defaultValue].displayText
        answerDisplayTextLabel.text = surveyQuestion.answers[defaultValue].title
        
        answerIconImageView.downloaded(from: surveyQuestion.answers[defaultValue].iconURL ?? "")

    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        delegate?.onPreviousQuestion(index: questionIndex)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        delegate?.onQuestioncompleted(index: questionIndex)
    }
    
}

extension SurveySliderViewController : SliderValueChange{
    func onSliderValueChanged(index : Int){
        answerDescriptionLabel.text = surveyQuestion.answers[index].displayText
        answerDisplayTextLabel.text = surveyQuestion.answers[index].title
        for answer in surveyQuestion.answers{
            answer.selected = false
        }
        surveyQuestion.answers[index].selected = true
    }
}

protocol SliderValueChange : class {
    func onSliderValueChanged(index : Int)
}


