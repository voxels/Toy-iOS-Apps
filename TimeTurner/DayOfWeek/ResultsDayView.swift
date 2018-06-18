//
//  ResultsDayView.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

/// Default values for the results day view
struct ResultsDayViewDefaults {
    static let dayViewCornerRadius:CGFloat = 8.0
    static let dayViewBorderWidth:CGFloat = 2.0
    static let dayViewSize:CGSize = CGSize(width: 44.0, height: 44.0)
    static let dayViewAnimationDuration:TimeInterval = 0.2
}

class ResultsDayView : UIView
{
    /// The parent model delegate used to check and update the model
    weak var modelDelegate:ParentModelDelegate? {
        didSet {
            guard let model = modelDelegate?.modelController() else {
                assert(false, "No model found")
            }
            buildView(for: model)
        }
    }
    
    /// An array of custom constraints for auto layout
    var customConstraints = [NSLayoutConstraint]()
    
    /// The day index
    var dayIndex:Int = 0
    {
        didSet{
            guard let model = modelDelegate?.modelController() else {
                return
            }
            rebuildView(for:model)
        }
    }
    
    /// The day view title label
    var title:UILabel = UILabel(frame: CGRect.zero)
    
    /// The appearance attributes for an unselected day
    let titleAttributes = [NSAttributedStringKey.font : UIFont.appFontButton(), NSAttributedStringKey.foregroundColor : UIColor.appMagentaColor()]

    /// The appearance attributes for a selected day
    let titleSelectedAttributes = [NSAttributedStringKey.font : UIFont.appFontButton(), NSAttributedStringKey.foregroundColor : UIColor.appGoldColor()]

    /// A flag for the selected day
    var isSelected:Bool = false
    {
        didSet{
            didUpdateSelected()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize
    {
        return ResultsDayViewDefaults.dayViewSize
    }
}

// MARK: - Build View Hierarchy

extension ResultsDayView {
    /**
     Builds the day view and requests an auto layout cycle
     - parameter model: the model controller
     - Returns: void
     */
    func buildView(for model:ModelController)
    {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        layer.masksToBounds = true
        layer.borderWidth = ResultsDayViewDefaults.dayViewBorderWidth
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        addSubview(title)
        rebuildView(for: model)
        
        setNeedsUpdateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
}


// MARK: - Configure

extension ResultsDayView {
    
    /**
     Rebuilds the view from the current model
     - parameter model: the model controller
     - Returns: void
    */
    func rebuildView(for model:ModelController)
    {
        if isSelected
        {
            configureAsSelectedView(for: model)
        }
        else
        {
            configureAsDefaultView(for: model)
        }
        
        layoutIfNeeded()
    }
    
    /**
     Configures the view with the default appearance
     - parameter model: the model controller
     - Returns: void
     */
    func configureAsDefaultView(for model:ModelController)
    {
        let cAnimation = cornerAnimation(toValue: ResultsDayViewDefaults.dayViewCornerRadius, duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        let bAnimation = borderColorAnimation(toValue: UIColor.appMagentaColor().cgColor, duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        let group = animationGroup(animations: [cAnimation, bAnimation], duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        
        layer.cornerRadius = ResultsDayViewDefaults.dayViewCornerRadius
        layer.borderColor = UIColor.appMagentaColor().cgColor
        title.attributedText = NSAttributedString(string: Date.dayAbbreviation(index: dayIndex, for:Settings.storedLocale()), attributes: titleAttributes)
        
        layer.add(group, forKey: "layerTransformation")
        
        guard model.lastSelectedDay != model.selectedDay, dayIndex == model.lastSelectedDay || dayIndex == model.selectedDay else { return }
        
        UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
            self?.title.alpha = 0.0
        }) { (completed:Bool) in
            UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration, animations: { [weak self] in
                self?.title.alpha = 1.0
            }, completion: { (completed:Bool) in
                
            })
        }
    }
    
    /**
     Configures the view with the selected appearance
     - parameter model: the model controller
     - Returns: void
     */
    func configureAsSelectedView(for model:ModelController)
    {
        let cAnimation = cornerAnimation(toValue: ResultsDayViewDefaults.dayViewSize.width / 2.0, duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        let bAnimation = borderColorAnimation(toValue: UIColor.appGoldColor().cgColor, duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        let group = animationGroup(animations: [cAnimation, bAnimation], duration:ResultsDayViewDefaults.dayViewAnimationDuration)
        
        layer.cornerRadius = ResultsDayViewDefaults.dayViewSize.width / 2.0
        layer.borderColor = UIColor.appGoldColor().cgColor
        title.attributedText = NSAttributedString(string: Date.dayAbbreviation(index: dayIndex, for:Settings.storedLocale()), attributes: titleSelectedAttributes)
        
        layer.add(group, forKey: "layerTransformation")
        
        guard model.lastSelectedDay != model.selectedDay, dayIndex == model.lastSelectedDay || dayIndex == model.selectedDay else { return }

        UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
            self?.title.alpha = 0.0
        }) { (completed:Bool) in
            UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration, animations: { [weak self] in
                self?.title.alpha = 1.0
            }, completion: { (completed:Bool) in
                
            })
        }
    }
}

extension ResultsDayView {
    /**
     Constructs a border corner animation
     - parameter toValue: the CGColor to animate towards
     - parameter duration: the duration of the animation
     - Returns: a configured CABasicAnimation
     */
    func cornerAnimation(toValue:CGFloat, duration:CFTimeInterval)->CABasicAnimation
    {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = layer.cornerRadius
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }
    
    /**
     Constructs a border color animation
     - parameter toValue: the CGColor to animate towards
     - parameter duration: the duration of the animation
     - Returns: a configured CABasicAnimation
     */
    func borderColorAnimation(toValue:CGColor, duration:CFTimeInterval)->CABasicAnimation
    {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = layer.borderColor
        animation.toValue = toValue
        animation.duration = duration
        return animation
    }
    
    /**
     Constructs an configured animation group for the given animations
     - parameter animations: an array of basic animations to group
     - parameter duration: the duration of the grouped animations
     - Returns: an animation group
     */
    func animationGroup(animations:[CABasicAnimation], duration:CFTimeInterval)->CAAnimationGroup
    {
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = 1
        group.autoreverses = false
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = animations
        return group
    }
}

// MARK: - Constraints

extension ResultsDayView {
    override func updateConstraints() {
        super.updateConstraints()
        
        if customConstraints.count > 0
        {
            removeConstraints(customConstraints)
            customConstraints.removeAll()
        }
        
        if subviews.contains(title)
        {
            let centerXConstraint = NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let centerYConstraint = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            customConstraints.append(contentsOf: [centerXConstraint, centerYConstraint])
        }
        
        addConstraints(customConstraints)
    }
}

// MARK: - Actions

extension ResultsDayView {
    /**
     Fetches the model and rebuilds the view when the selected day is updated
     - Returns: void
     */
    func didUpdateSelected()
    {
        guard let model = modelDelegate?.modelController() else {
            return
        }
        rebuildView(for:model)
    }
}

