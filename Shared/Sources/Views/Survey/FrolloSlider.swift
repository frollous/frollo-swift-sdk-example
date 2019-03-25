//
//  FrolloSlider.swift
//  FrolloSDK iOS Example
//
//  Created by Dipesh Dhakal on 18/3/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class FrolloSlider: UIView {
    
    var minValue = 0
    var maxValue = 4
    
    var selectedValue : Int = 0{
        didSet{
            updateDefautValue()
        }
    }
    
    var slider : UISlider?
    var stackView  :UIStackView?
    weak var delegate : SliderValueChange?
    var values : [String]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    func updateDefautValue(){
        slider?.minimumValue = Float(minValue)
        slider?.maximumValue = Float(maxValue)
        slider?.value = Float(selectedValue)
        stackView?.removeAllArrangedSubviews()
        for index in 0...maxValue{
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = values[index]
            label.textAlignment = .center
            label.textColor = UIColor.black
            if(index == selectedValue){
                label.textColor = UIColor.blue
                delegate?.onSliderValueChanged(index : index)
            }
            stackView?.addArrangedSubview(label)
        }
    }
    
    func setUpViews(){
        if(stackView == nil){
            stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: frame.width , height: frame.height / 3))
            stackView?.alignment = .center
            stackView?.axis = .horizontal
            stackView?.distribution = .equalSpacing
            addSubview(stackView!)
        }
        if(slider == nil){
            slider = UISlider(frame: CGRect(x: 0, y: frame.height / 3, width: frame.width, height: frame.height * 2 / 3))
            slider?.addTarget(self, action: #selector(FrolloSlider.sliderValueDidChange(_:)), for: .valueChanged)
             addSubview(slider!)
        }
        
        slider?.minimumValue = Float(minValue)
        slider?.maximumValue = Float(maxValue)
        slider?.value = Float(selectedValue)
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        let roundedStepValue = round(sender.value)
        sender.value = roundedStepValue
        selectedValue = Int(roundedStepValue)
        print("Slider step value \(Int(roundedStepValue))")
    }
    
}


extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
