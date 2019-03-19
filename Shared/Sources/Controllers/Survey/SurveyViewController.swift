//
//  SurveyViewController.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 15/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit
import FrolloSDK

class SurveyViewController: UIPageViewController {
    
    fileprivate lazy var surveyQuestions = [UIViewController]()
    var survey : Survey!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let loadingVC = storyboard!.instantiateViewController(withIdentifier: "SurveyLoadingViewController") as! SurveyLoadingViewController
        setViewControllers([loadingVC], direction: .forward, animated: true, completion: nil)
        
        FrolloSDK.shared.surveys.fetchSurvey(surveyKey: "APP_TESTING") { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let survey):
                self.survey = survey
                self.showSurveyQuestions()
                break
            }
        }
    }
    
    func updateSurvey(){
        
        for question in survey.questions{
            for answer in question.answers{
                if(answer.selected){
                    question.answers = [answer]
                    break
                }
            }
        }

        FrolloSDK.shared.surveys.submitSurvey(survey: survey) { (result) in
            switch result{
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let survey):
                print(survey.key)
                break
            }
        }
    }

    
    func showSurveyQuestions(){
        
        for (index, question) in survey.questions.enumerated(){
            surveyQuestions.append(getSurveyViewController(question: question, index: index))
        }
        if let firstQuestion = surveyQuestions.first{
            setViewControllers([firstQuestion], direction: .forward, animated: true, completion: nil)
        }
            
    }
    
    fileprivate func getSurveyViewController(question : SurveyQuestion, index : Int) -> UIViewController
    {
        switch question.type {
        case .multipleChoice:
            let vc = storyboard!.instantiateViewController(withIdentifier: "SurveyMultipleChoiceViewController") as! SurveyMultipleChoiceViewController
            vc.questionIndex = index
            vc.surveyQuestion = question
            vc.delegate = self
            return vc
        case .slider:
            let vc = storyboard!.instantiateViewController(withIdentifier: "SurveySliderViewController") as! SurveySliderViewController
            vc.questionIndex = index
            vc.surveyQuestion = question
            vc.delegate = self
            return vc
        }
    }
    
    func createSurvey() -> Survey? {
        let jsonString = "{\"id\": 4,\"key\": \"FINANCIAL_WELLBEING_4\",\"name\": \"Wellbeing Survey\",\"questions\": [{\"id\": 4,\"type\": \"multiple_choice\",\"title\": \"How do you feel about your finances?\",\"display_text\": \"This let' us understand the level of support we should give you to keep you on the right track.\",\"answers\": [{\"id\": 12,\"title\": \"NEEDS FIXING\",\"display_text\": \"Always feel overwhelmed and I am always worried about money.\",\"value\": \"1\",\"selected\": false},{\"id\": 13,\"title\": \"NOT GREAT\",\"display_text\": \"Often feel overwhelmed and I worry about my money.\",\"value\": \"2\",\"selected\": false},{\"id\": 14,\"title\": \"OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"value\": \"3\",\"selected\": true},{\"id\": 15,\"title\": \"GOOD\",\"display_text\": \"I feel comfortable about my money situations and rarely I worry about money.\",\"value\": \"4\",\"selected\": false},{\"id\": 16,\"title\": \"GREAT\",\"display_text\": \"Have mastered my finance and never worry about money.\",\"value\": \"5\",\"selected\": false}]},{\"id\": 3,\"type\": \"slider\",\"title\": \"Frollo is here to help you!\",\"display_text\": \"We aim to personalise every experience. So we can provide you with meaningful financial direction, please let us know why you are here. I am here to...\",\"answers\": [{\"id\": 9,\"display_text\": \"Save for a goal\",\"value\": \"1\",\"selected\": true},{\"id\": 10,\"display_text\": \"Find out where my money goes\",\"value\": \"2\",\"selected\": false},{\"id\": 11,\"display_text\": \"Get support in paying off debt\",\"value\": \"3\",\"selected\": false},{\"id\": 12,\"display_text\": \"New Option\",\"value\": \"4\",\"selected\": false},{\"id\": 13,\"display_text\": \"Last One\",\"value\": \"5\",\"selected\": false}]}]}"
        
        if let jsonData = jsonString.data(using: .utf8)
        {
            let survey = try? JSONDecoder().decode(Survey.self, from: jsonData)
            return survey
        }
        return nil
    }
}

extension SurveyViewController : SurveyQuestionCompleted{
    func onQuestioncompleted(index: Int) {
        if(index < surveyQuestions.count-1){
            setViewControllers([surveyQuestions[index+1]], direction: .forward, animated: true, completion: nil)
        }else{
            // call update survey api
            updateSurvey()
        }
        
    }
    
    func onPreviousQuestion(index : Int){
        if(index > 0){
            setViewControllers([surveyQuestions[index-1]], direction: .reverse, animated: true, completion: nil)
        }
    }
}

protocol SurveyQuestionCompleted : class{
    func onQuestioncompleted(index : Int)
    func onPreviousQuestion(index : Int)
}
