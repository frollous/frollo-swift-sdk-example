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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        FrolloSDK.shared.surveys.fetchSurvey(surveyKey: "FINANCIAL_WELLBEING") { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let survey):
                self.showSurveyQuestions(survey:survey)
                break
            }
        }
    }
    
    func showSurveyQuestions(survey:Survey?){
        if let survey = survey{
            for question in survey.questions!{
                surveyQuestions.append(getSurveyViewController(question: question))
            }
            setViewControllers(surveyQuestions, direction: .forward, animated: true, completion: nil)
        }
    }
    
    fileprivate func getSurveyViewController(question : SurveyQuestion) -> UIViewController
    {
        switch question.type! {
        case .multipleChoice:
            let vc = storyboard!.instantiateViewController(withIdentifier: "SurveyMultipleChoiceViewController") as! SurveyMultipleChoiceViewController
            vc.surveyQuestion = question
            return vc
        case .slider:
            let vc = storyboard!.instantiateViewController(withIdentifier: "SurveySliderViewController") as! SurveySliderViewController
            vc.surveyQuestion = question
            return vc
        }
    }
    
}

extension SurveyViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = surveyQuestions.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return surveyQuestions.last }
        
        guard surveyQuestions.count > previousIndex else { return nil        }
        
        return surveyQuestions[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = surveyQuestions.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < surveyQuestions.count else {
            return nil
        }
        
        guard surveyQuestions.count > nextIndex else { return nil}
        
        return surveyQuestions[nextIndex]
    }
}

extension SurveyViewController: UIPageViewControllerDelegate { }
