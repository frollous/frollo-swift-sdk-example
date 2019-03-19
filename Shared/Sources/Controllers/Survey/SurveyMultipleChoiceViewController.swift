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
    
    var surveyQuestion : SurveyQuestion!
    var questionIndex : Int!
    weak var delegate : SurveyQuestionCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = surveyQuestion.title
        displayLabel.text = surveyQuestion.displayText ?? ""
        answerTableView.tableFooterView = UIView()
        answerTableView.rowHeight = 45
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        delegate?.onPreviousQuestion(index: questionIndex)
    }
    
    @IBAction func nextPress(_ sender: Any) {
        delegate?.onQuestioncompleted(index: questionIndex)
    }
    
    func selectAnswer(indexPath : IndexPath){
        
        for answer in surveyQuestion.answers{
            answer.selected = false
        }
        surveyQuestion.answers[indexPath.item].selected = true

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
        let answer = surveyQuestion.answers[indexPath.item]
        cell.answerTitleLabel.text = answer.displayText ?? ""
        cell.answerImage.isHidden = !answer.selected
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAnswer(indexPath: indexPath)
    }
}


