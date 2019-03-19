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
    var activityLoader = UIActivityIndicatorView(style: .gray)
    var survey : Survey!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // add loading indicator
        activityLoader.startAnimating()
        activityLoader.center = view.center
        self.view.addSubview(activityLoader)
        
        // fetch surveys from api
        FrolloSDK.shared.surveys.fetchSurvey(surveyKey: "APP_TESTING") { (result) in
            self.activityLoader.stopAnimating()
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
        activityLoader.startAnimating()
        
        // filter out unselected answers since api only expects selected answers in array
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
                self.navigationController?.popViewController(animated: true)
                break
            }
        }
    }

    // create list of viewcontroller array and display first viewcontroller
    func showSurveyQuestions(){
        
        for (index, question) in survey.questions.enumerated(){
            surveyQuestions.append(getSurveyViewController(question: question, index: index))
        }
        if let firstQuestion = surveyQuestions.first{
            setViewControllers([firstQuestion], direction: .forward, animated: true, completion: nil)
        }
            
    }
    
    // create viewcontroller pages for each questions depending on the type
    fileprivate func getSurveyViewController(question : Survey.Question, index : Int) -> UIViewController
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
    
}

extension SurveyViewController : SurveyQuestionCompleted{
    
    //next button pressed
    func onQuestioncompleted(index: Int) {
        if(index < surveyQuestions.count-1){
            setViewControllers([surveyQuestions[index+1]], direction: .forward, animated: true, completion: nil)
        }else{
            // all pages completed. call update survey api
            updateSurvey()
        }
        
    }
    
    // previous button pressed
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
