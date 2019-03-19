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
    
    @IBOutlet weak var answerDescriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var answerSlider: FrolloSlider!
    
    var surveyQuestion : SurveyQuestion!
    var questionIndex : Int!
    weak var delegate : SurveyQuestionCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = surveyQuestion?.title ?? ""
        displayLabel.text = surveyQuestion?.displayText ?? ""
        answerSlider.delegate = self
        
        setDynamicSlider()
    }
    
    func setDynamicSlider(){
        guard let answers = surveyQuestion?.answers else { return }
        answerSlider.minValue = 1
        answerSlider.maxValue = answers.count
        var values = [String]()
        var defaultValue = 1
        for (i,answer) in answers.enumerated(){
            values.append(answer.value)
            if(answer.selected){
                defaultValue = i + 1
            }
        }
        answerSlider.values = values
        answerSlider.selectedValue = defaultValue
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
        for answer in surveyQuestion.answers{
            answer.selected = false
        }
        surveyQuestion.answers[index].selected = true
    }
}

protocol SliderValueChange : class {
    func onSliderValueChanged(index : Int)
}
