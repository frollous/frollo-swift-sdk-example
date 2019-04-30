//
//  SurveyMultipleChoiceViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 15/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit
import FrolloSDK

class SurveyMultipleChoiceViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var surveyQuestion : Survey.Question!
    var questionIndex : Int!
    weak var delegate : SurveyQuestionCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = surveyQuestion.title
        displayLabel.text = surveyQuestion.displayText ?? ""
        answerTableView.tableFooterView = UIView()
        answerTableView.estimatedRowHeight = 45
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        delegate?.onPreviousQuestion(index: questionIndex)
    }
    
    @IBAction func nextPress(_ sender: Any) {
        delegate?.onQuestioncompleted(index: questionIndex)
    }
    
    // set selected row and unset all others
    func selectAnswer(indexPath : IndexPath){
        if(surveyQuestion.type == .checkbox){
            surveyQuestion.answers[indexPath.item].selected = !surveyQuestion.answers[indexPath.item].selected
        }else{
            for answer in surveyQuestion.answers{
                answer.selected = false
            }
            surveyQuestion.answers[indexPath.item].selected = true
        }
        
        answerTableView.reloadData()
    }
    
    
}

extension SurveyMultipleChoiceViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyQuestion.answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyAnswerTableCell") as! SurveyAnswerTableCell
        cell.answer = surveyQuestion.answers[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAnswer(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let answer = surveyQuestion.answers[indexPath.item]
        if(answer.answerType == .selection){
            return 40
        }else{
            return 75
        }
        
    }
}


