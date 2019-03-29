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
        FrolloSDK.shared.surveys.fetchSurvey(surveyKey: "CHANGE_TESTING") { (result) in
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
        
//        self.survey = self.createSurvey()!
//        self.showSurveyQuestions()
    }
    
    func updateSurvey(){
//        activityLoader.startAnimating()
        
        // filter out unselected answers since api only expects selected answers in array
        for question in survey.questions{
            var selectedAnswers = [Survey.Question.Answer]()
            for answer in question.answers{
                if(answer.selected){
                    selectedAnswers.append(answer)
                }
            }
            question.answers = selectedAnswers
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
        case .checkbox:
            let vc = storyboard!.instantiateViewController(withIdentifier: "SurveyMultipleChoiceViewController") as! SurveyMultipleChoiceViewController
            vc.questionIndex = index
            vc.surveyQuestion = question
            vc.delegate = self
            return vc
        }
    }
    
    func createSurvey() -> Survey? {
        let jsonString = "{\"id\": 1,\"key\": \"FINANCIAL_WELLBEING\",\"name\": \"Wellbeing Survey\",\"questions\": [{\"id\": 1,\"type\": \"multiple_choice\",\"title\": \"How do you feel about your finances?\",\"display_text\": \"This let's us understand the level of support we should give you to keep you on the right track.\",\"icon_url\": \"https://content.frollo.us/surveys/images/question_icon.png\",\"optional\": false,\"answers\": [{\"id\": 1,\"type\": \"selection\",\"title\": \"1 OK\",\"display_text\": \"1 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"1\",\"selected\": false},{\"id\": 2,\"type\": \"selection\",\"title\": \"2 OK\",\"display_text\": \"2 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"2\",\"selected\": false},{\"id\": 3,\"type\": \"selection\",\"title\": \"3 OK\",\"display_text\": \"3 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"3\",\"selected\": true},{\"id\": 4,\"type\": \"freeform\",\"title\": \"4 OK\",\"display_text\": \"4 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"4\",\"selected\": false}]},{\"id\": 1,\"type\": \"checkbox\",\"title\": \"How do you feel about your finances?\",\"display_text\": \"This let's us understand the level of support we should give you to keep you on the right track.\",\"icon_url\": \"https://content.frollo.us/surveys/images/question_icon.png\",\"optional\": false,\"answers\": [{\"id\": 1,\"type\": \"selection\",\"title\": \"1 OK\",\"display_text\": \"10 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"1\",\"selected\": false},{\"id\": 20,\"type\": \"selection\",\"title\": \"2 OK\",\"display_text\": \"20 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"2\",\"selected\": false},{\"id\": 3,\"type\": \"selection\",\"title\": \"3 OK\",\"display_text\": \"30 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"3\",\"selected\": true},{\"id\": 4,\"type\": \"selection\",\"title\": \"4 OK\",\"display_text\": \"40 I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://content.frollo.us/surveys/images/medium_face_emoji.png\",\"value\": \"4\",\"selected\": false}]},{\"id\": 1,\"type\": \"slider\",\"title\": \"How do you feel about your finances?\",\"display_text\": \"This let's us understand the level of support we should give you to keep you on the right track.\",\"icon_url\": \"https://content.frollo.us/surveys/images/question_icon.png\",\"optional\": false,\"answers\": [{\"id\": 1,\"type\": \"selection\",\"title\": \"1OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Noto_Emoji_KitKat_263a.svg/1200px-Noto_Emoji_KitKat_263a.svg.png\",\"value\": \"1\",\"selected\": false},{\"id\": 1,\"type\": \"selection\",\"title\": \"2OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Noto_Emoji_KitKat_263a.svg/1200px-Noto_Emoji_KitKat_263a.svg.png\",\"value\": \"2\",\"selected\": false},{\"id\": 1,\"type\": \"selection\",\"title\": \"3OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Noto_Emoji_KitKat_263a.svg/1200px-Noto_Emoji_KitKat_263a.svg.png\",\"value\": \"3\",\"selected\": true},{\"id\": 1,\"type\": \"selection\",\"title\": \"4OK\",\"display_text\": \"I know enough but need to put things into practice. Sometimes I worry about money.\",\"icon_url\": \"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e6/Noto_Emoji_KitKat_263a.svg/1200px-Noto_Emoji_KitKat_263a.svg.png\",\"value\": \"4\",\"selected\": false}]}]}"
        
        if let jsonData = jsonString.data(using: .utf8)
        {
            let survey = try? JSONDecoder().decode(Survey.self, from: jsonData)
            return survey
        }
        return nil
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
