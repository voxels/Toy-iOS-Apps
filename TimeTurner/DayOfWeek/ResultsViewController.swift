//
//  ResultsViewController.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit
import CoreGraphics

/// Default values for the results view
struct ResultsViewDefaults {
    static let dateFontSize:CGFloat = 17.0
    static let horizontalMargin:CGFloat = 10.0
    static let subheadingVerticalMargin:CGFloat = 8.0
    static let daySpacingMax:CGFloat = 28.75
    static let dayTopRowCount:Int = 3
    static let dayWeekdaysCount:Int = 7
    static let labelAnimationScale:CGFloat = 1.1
    static let copiedLabelAnimationDuration:TimeInterval = 2.0
}

class ResultsViewController : UIViewController {
    
    /// The parent model delegate used to check and update the model
    weak var modelDelegate:ParentModelDelegate? {
        didSet {
            guard let model = modelDelegate?.modelController() else {
                assert(false, "No model found for Results View Controller")
            }
            
            registerForNotifications()
            buildViews(for: model)
        }
    }
    
    /// An array of custom constraints for auto layout
    var customConstraints = [NSLayoutConstraint]()
    
    /// The container view
    var containerView = UIView(frame:CGRect.zero)
    
    /// The day view
    var dayContainer = UIView(frame:CGRect.zero)
    
    /// The stack view container
    var stackViewContainer = UIView(frame:CGRect.zero)
    
    /// The top day row container view
    var topDayContainerView:UIView?
    
    /// The bottom day row container view
    var bottomDayContainerView:UIView?

    /// An array of the top day views
    var topDayViews = [ResultsDayView]()
    
    /// An array of the bottom day views
    var bottomDayViews = [ResultsDayView]()
    
    /// The day subheading label
    var daySubheadingLabel:UILabel = UILabel(frame: CGRect.zero)
    
    /// The spacing between day views
    var daySpacing:CGFloat = 0.0
    
    /// The ISO label container view
    var isoContainer = UIView(frame:CGRect.zero)
    
    /// The ISO label
    var isoLabel:UILabel = UILabel(frame: CGRect.zero)
    
    /// The ISO Subheading label
    var isoSubheadingLabel:UILabel = UILabel(frame:CGRect.zero)
    
    /// The ISO Label tap gesture
    var isoLabelGesture = UITapGestureRecognizer()
    
    /// The ISO "copied" label
    var isoCopiedLabel:UILabel = UILabel(frame:CGRect.zero)
    
    /// The count label container view
    var countContainer = UIView(frame:CGRect.zero)
    
    /// The count label
    var countLabel:UILabel = UILabel(frame:CGRect.zero)
    
    /// The count subheading label
    var countSubheadingLabel:UILabel = UILabel(frame: CGRect.zero)
    
    /// The date subheading label
    var dateSubheadingLabel:UILabel = UILabel(frame:CGRect.zero)
    
    /// The count label tap gesture
    var countLabelGesture = UITapGestureRecognizer()
    
    /// The count "copied" label
    var countCopiedLabel:UILabel = UILabel(frame: CGRect.zero)
    
    /// Appearance attributes for a title label
    let titleLabelAttributes = [NSAttributedStringKey.font:UIFont.appFontTitle(), NSAttributedStringKey.foregroundColor:UIColor.appGoldColor()]

    /// Appearance attributes for a subheading label
    let subheadingLabelAttributes = [NSAttributedStringKey.font:UIFont.appFontTagline(), NSAttributedStringKey.foregroundColor:UIColor.appNeutralColor()]
    
    /// Appearance attributes for a date label
    let dateLabelAttributes = [NSAttributedStringKey.font:UIFont.appFontSized(size: ResultsViewDefaults.dateFontSize), NSAttributedStringKey.foregroundColor:UIColor.appNeutralColor()]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Build View Hierarchy

extension ResultsViewController {

    /**
     Builds the views for the controller and requests an autolayout update cycle
     - parameter model: The model controller
     - Returns: void
     */
    func buildViews(for model:ModelController)
    {
        view.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        buildDayContainer(for: model)
        buildIsoContainer(for: model)
        buildCountContainer(for: model)
        view.addSubview(containerView)
    }
    
    /**
     Builds the day container view
     - parameter model: The model controller
     - Returns: void
     */
    func buildDayContainer(for model:ModelController)
    {
        dayContainer.translatesAutoresizingMaskIntoConstraints = false
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        daySubheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topDayContainerView = UIView(frame:CGRect.zero)
        bottomDayContainerView = UIView(frame:CGRect.zero)
        topDayContainerView?.translatesAutoresizingMaskIntoConstraints = false
        bottomDayContainerView?.translatesAutoresizingMaskIntoConstraints = false
        
        daySpacing = min((view.bounds.size.width - 2.0 * ResultsViewDefaults.horizontalMargin - 5.0 * ResultsDayViewDefaults.dayViewSize.width) / 4.0, ResultsViewDefaults.daySpacingMax)
        
        topDayViews = buildTopDayViews()
        bottomDayViews = buildBottomDayViews()
        
        for view in topDayViews
        {
            topDayContainerView?.addSubview(view)
        }
        
        for view in bottomDayViews
        {
            bottomDayContainerView?.addSubview(view)
        }
        
        stackViewContainer.addSubview(topDayContainerView!)
        stackViewContainer.addSubview(bottomDayContainerView!)
        
        daySubheadingLabel.attributedText = NSAttributedString(string: model.daySubheadingTitle, attributes: subheadingLabelAttributes)
        daySubheadingLabel.textAlignment = .center
        
        dayContainer.addSubview(stackViewContainer)
        dayContainer.addSubview(daySubheadingLabel)
        containerView.addSubview(dayContainer)
        
        updateSelectedDay(for: model)
    }
    
    /**
     Builds the top day view array
     - Returns: an array of results day views
     */
    func buildTopDayViews()->[ResultsDayView]
    {
        return buildDayViews(startIndex: 0, endIndex: ResultsViewDefaults.dayTopRowCount)
    }

    /**
     Builds the bottom day view array
     - Returns: an array of results day views
     */
    func buildBottomDayViews()->[ResultsDayView]
    {
        return buildDayViews(startIndex: ResultsViewDefaults.dayTopRowCount, endIndex: ResultsViewDefaults.dayWeekdaysCount)
    }
    
    /**
     Constructs an array of day views from one day index to another day index
     - parameter startIndex: the day index that begins the array of day views
     - parameter endIndex: the day index that ends teh array of day views
     - Returns: an array of ResultsDayView
     */
    func buildDayViews(startIndex:Int, endIndex:Int)->[ResultsDayView]
    {
        var retval = [ResultsDayView]()
        
        for index in startIndex...endIndex - 1
        {
            let view = ResultsDayView(frame: CGRect(x: 0.0, y: 0.0, width: ResultsDayViewDefaults.dayViewSize.width, height: ResultsDayViewDefaults.dayViewSize.height))
            view.modelDelegate = modelDelegate
            view.dayIndex = index
            retval.append(view)
        }
        
        return retval
    }
    
    /**
     Builds the ISO label container
     - parameter model: The model controller
     - Returns: void
     */
    func buildIsoContainer(for model:ModelController)
    {
        isoContainer.translatesAutoresizingMaskIntoConstraints = false
        isoLabel.translatesAutoresizingMaskIntoConstraints = false
        isoSubheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        isoCopiedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        updateIsoLabel(for: model)
        isoSubheadingLabel.attributedText = NSAttributedString(string: "ISO 8601", attributes: subheadingLabelAttributes)
        
        isoLabel.textAlignment = .center
        isoSubheadingLabel.textAlignment = .center
        
        isoLabel.numberOfLines = 1
        isoLabel.adjustsFontSizeToFitWidth = true
        
        isoContainer.addSubview(isoLabel)
        isoContainer.addSubview(isoSubheadingLabel)
        containerView.addSubview(isoContainer)
        
        isoLabelGesture.numberOfTapsRequired = 1
        isoLabelGesture.addTarget(self, action: #selector(onTapLabel(recognizer:)))
        isoLabel.addGestureRecognizer(isoLabelGesture)
        isoLabel.isUserInteractionEnabled = true
        
        isoCopiedLabel.attributedText = NSAttributedString(string: "Copied to clipboard", attributes: self
            .subheadingLabelAttributes)
        isoCopiedLabel.isHidden = true
        isoContainer.addSubview(isoCopiedLabel)
    }
    
    /**
     Builds the count label container
     - parameter model: The model controller
     - Returns: void
     */
    func buildCountContainer(for model:ModelController)
    {
        countContainer.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countSubheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        dateSubheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        countCopiedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.textAlignment = .center
        countSubheadingLabel.textAlignment = .center
        dateSubheadingLabel.textAlignment = .center
        
        countSubheadingLabel.attributedText = NSAttributedString(string: model.countSubheadingTitle, attributes: subheadingLabelAttributes)

        updateCountLabels(for: model)
        
        countContainer.addSubview(countLabel)
        countContainer.addSubview(countSubheadingLabel)
        countContainer.addSubview(dateSubheadingLabel)

        containerView.addSubview(countContainer)
        
        countLabelGesture.numberOfTapsRequired = 1
        countLabelGesture.addTarget(self, action: #selector(onTapLabel(recognizer:)))
        countLabel.addGestureRecognizer(countLabelGesture)
        countLabel.isUserInteractionEnabled = true
        
        countCopiedLabel.attributedText = NSAttributedString(string: "Copied to clipboard", attributes: self
            .subheadingLabelAttributes)
        countCopiedLabel.isHidden = true
        countContainer.addSubview(countCopiedLabel)
    }
}

// MARK: - Refresh View

extension ResultsViewController {
    /**
     Performs an action when the model did update notification is received
     - Returns: void
     */
    @objc func modelDidUpdate()
    {
        guard let model = modelDelegate?.modelController() else {
            return
        }
        
        updateSelectedDay(for: model)
        updateIsoLabel(for: model)
        updateCountLabels(for: model)
    }
    
    /**
     Updates the is selected flag based on the selected day
     - parameter model: the model controller
     - Returns: void
     */
    func updateSelectedDay(for model:ModelController)
    {
        if model.selectedDay >= 0 && model.selectedDay < topDayViews.count
        {
            for view in bottomDayViews
            {
                view.isSelected = false
            }
            
            for (index, view) in topDayViews.enumerated()
            {
                if index == model.selectedDay
                {
                    view.isSelected = true
                }
                else
                {
                    view.isSelected = false
                }
            }
        }
        else if model.selectedDay >= topDayViews.count && model.selectedDay < topDayViews.count + bottomDayViews.count
        {
            for view in topDayViews
            {
                view.isSelected = false
            }
            
            let checkIndex = model.selectedDay - topDayViews.count
            
            for (index, view) in bottomDayViews.enumerated()
            {
                if index == checkIndex
                {
                    view.isSelected = true
                }
                else
                {
                    view.isSelected = false
                }
            }
        }
    }
    
    /**
     Updates the ISO label with an animation
     - parameter model: The model controller
     - Returns: void
     */
    func updateIsoLabel(for model:ModelController)
    {
        isoLabel.attributedText = NSAttributedString(string: model.isoTitle, attributes: titleLabelAttributes)
        
        guard model.didChooseDate else { return }
        
        UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
            self?.isoLabel.transform = CGAffineTransform(scaleX: ResultsViewDefaults.labelAnimationScale, y: ResultsViewDefaults.labelAnimationScale)
        }) { (completed:Bool) in
            UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
                self?.isoLabel.transform = CGAffineTransform.identity
            }) { (completed:Bool) in
                
            }
        }
    }
    
    /**
     Updates the count label with an animation
     - parameter model: The model controller
     - Returns: void
     */
    func updateCountLabels(for model:ModelController)
    {
        countLabel.attributedText = NSAttributedString(string: model.countTitle, attributes: titleLabelAttributes)
        dateSubheadingLabel.attributedText = NSAttributedString(string: model.countDateTitle, attributes: dateLabelAttributes)
        
        guard model.didChooseDate else { return }

        UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
            self?.countLabel.transform = CGAffineTransform(scaleX: ResultsViewDefaults.labelAnimationScale, y: ResultsViewDefaults.labelAnimationScale)
        }) { (completed:Bool) in
            UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: { [weak self] in
                self?.countLabel.transform = CGAffineTransform.identity
            }) { (completed:Bool) in
                
            }
        }
    }
}

// MARK: - Notifications

extension ResultsViewController {
    
    /**
     Deregisters for notificaitons
     - Returns: void
     */
    func deregisterForNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(ModelNotification.modelDidUpdate), object: nil)
    }
    
    /**
     Registers for Notifications
     - Returns: void
     */
    func registerForNotifications()
    {
        deregisterForNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(modelDidUpdate), name: Notification.Name.init(ModelNotification.modelDidUpdate), object: nil)
    }
}

// MARK: - Autolayout Constraints

extension ResultsViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if customConstraints.count > 0
        {
            view.removeConstraints(customConstraints)
            customConstraints.removeAll()
        }
        
        if containerView.subviews.contains(dayContainer)
        {
            if dayContainer.subviews.contains(stackViewContainer) && dayContainer.subviews.contains(daySubheadingLabel)
            {
                guard bottomDayContainerView != nil, bottomDayContainerView != nil else { return }
                
                for (index, view) in topDayViews.enumerated()
                {
                    let centerYConstraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: topDayContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                    let leftConstraint = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: topDayContainerView, attribute: .left, multiplier: 1.0, constant: (ResultsDayViewDefaults.dayViewSize.width + daySpacing) * CGFloat(index))
                    let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.width)
                    let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.height)
                    customConstraints.append(contentsOf: [centerYConstraint, leftConstraint, widthConstraint, heightConstraint])
                }
                
                for (index, view) in bottomDayViews.enumerated()
                {
                    let centerYConstraint = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: bottomDayContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                    let leftConstraint = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: bottomDayContainerView, attribute: .left, multiplier: 1.0, constant: (ResultsDayViewDefaults.dayViewSize.width + daySpacing) * CGFloat(index))
                    let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.width)
                    let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.height)
                    customConstraints.append(contentsOf: [centerYConstraint, leftConstraint, widthConstraint, heightConstraint])
                }
                
                if stackViewContainer.subviews.contains(topDayContainerView!) && stackViewContainer.subviews.contains(bottomDayContainerView!)
                {
                    let centerYConstraint = NSLayoutConstraint(item: stackViewContainer, attribute: .centerY, relatedBy: .equal, toItem: dayContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                    let centerXConstraint = NSLayoutConstraint(item: stackViewContainer, attribute: .centerX, relatedBy: .equal, toItem: dayContainer, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                    let widthConstraint = NSLayoutConstraint(item: stackViewContainer, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0)
                    let stackVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[topDayView]-verticalSpacing-[bottomDayView]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: ["verticalSpacing":daySpacing], views: ["topDayView":topDayContainerView!, "bottomDayView": bottomDayContainerView!])
                    let topDayHeightConstraints = NSLayoutConstraint(item: topDayContainerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.height)
                    let bottomDayHeightConstraints = NSLayoutConstraint(item: bottomDayContainerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.height)
                    let topDayCenterXConstraint = NSLayoutConstraint(item: topDayContainerView!, attribute: .centerX, relatedBy: .equal, toItem: stackViewContainer, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                    let bottomDayCenterXConstraint = NSLayoutConstraint(item: bottomDayContainerView!, attribute: .centerX, relatedBy: .equal, toItem: topDayContainerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                    let topDayWidthConstraint = NSLayoutConstraint(item: topDayContainerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.width * CGFloat(topDayViews.count) + daySpacing * CGFloat(topDayViews.count - 1))
                    let bottomDayWidthConstraint = NSLayoutConstraint(item: bottomDayContainerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ResultsDayViewDefaults.dayViewSize.width * CGFloat(bottomDayViews.count) + daySpacing * CGFloat(bottomDayViews.count - 1))
                    let subheadingTopConstraint = NSLayoutConstraint(item: daySubheadingLabel, attribute: .top, relatedBy: .equal, toItem: stackViewContainer, attribute: .bottom, multiplier: 1.0, constant: daySpacing / 2.0)
                    let subheadingHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subheading]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["subheading": daySubheadingLabel])
                    
                    customConstraints.append(contentsOf:[centerYConstraint, centerXConstraint, widthConstraint])
                    customConstraints.append(contentsOf: [topDayHeightConstraints, bottomDayHeightConstraints])
                    customConstraints.append(contentsOf: stackVerticalConstraints)
                    customConstraints.append(contentsOf: [topDayCenterXConstraint, bottomDayCenterXConstraint, topDayWidthConstraint, bottomDayWidthConstraint])
                    customConstraints.append(contentsOf: subheadingHorizontalConstraints)
                    customConstraints.append(subheadingTopConstraint)
                }
            }
        }
        
        if containerView.subviews.contains(isoContainer)
        {
            if isoContainer.subviews.contains(isoLabel) && isoContainer.subviews.contains(isoSubheadingLabel) && isoContainer.subviews.contains(isoCopiedLabel)
            {
                let labelCenterYConstraints = NSLayoutConstraint(item: isoLabel, attribute: .centerY, relatedBy: .equal, toItem: isoContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                let subheadingTopConstraint = NSLayoutConstraint(item: isoSubheadingLabel, attribute: .top, relatedBy: .equal, toItem: isoLabel, attribute: .bottom, multiplier: 1.0, constant: ResultsViewDefaults.subheadingVerticalMargin)
                let labelHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[label]-margin-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: ["margin":ResultsViewDefaults.horizontalMargin], views: ["label":isoLabel])
                let subheadingHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subheading]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["subheading":isoSubheadingLabel])
                
                let copiedCenterXConstraint = NSLayoutConstraint(item: isoCopiedLabel, attribute: .centerX, relatedBy: .equal, toItem: isoLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                let copiedBottomConstraint = NSLayoutConstraint(item: isoCopiedLabel, attribute: .bottom, relatedBy: .equal, toItem: isoLabel, attribute: .top, multiplier: 1.0, constant: -1 * ResultsViewDefaults.subheadingVerticalMargin)
                
                customConstraints.append(contentsOf: [labelCenterYConstraints, subheadingTopConstraint])
                customConstraints.append(contentsOf: labelHorizontalConstraints)
                customConstraints.append(contentsOf: subheadingHorizontalConstraints)
                customConstraints.append(contentsOf: [copiedCenterXConstraint, copiedBottomConstraint])
            }
        }
        
        if containerView.subviews.contains(countContainer)
        {
            if countContainer.subviews.contains(countLabel) && countContainer.subviews.contains(countSubheadingLabel) && countContainer.subviews.contains(dateSubheadingLabel) && countContainer.subviews.contains(countCopiedLabel)
            {
                
                let labelCenterYConstraints = NSLayoutConstraint(item: countLabel, attribute: .centerY, relatedBy: .equal, toItem: countContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                let subheadingTopConstraint = NSLayoutConstraint(item: countSubheadingLabel, attribute: .top, relatedBy: .equal, toItem: countLabel, attribute: .bottom, multiplier: 1.0, constant: ResultsViewDefaults.subheadingVerticalMargin)
                let dateTopConstraint = NSLayoutConstraint(item: dateSubheadingLabel, attribute: .top, relatedBy: .equal, toItem: countSubheadingLabel, attribute: .bottom, multiplier: 1.0, constant: ResultsViewDefaults.subheadingVerticalMargin)
                let labelHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["label":countLabel])
                let subheadingHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subheading]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["subheading":countSubheadingLabel])
                let dateHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[date]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["date":dateSubheadingLabel])
                
                let copiedCenterXConstraint = NSLayoutConstraint(item: countCopiedLabel, attribute: .centerX, relatedBy: .equal, toItem: countLabel, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                let copiedBottomConstraint = NSLayoutConstraint(item: countCopiedLabel, attribute: .bottom, relatedBy: .equal, toItem: countLabel, attribute: .top, multiplier: 1.0, constant: -1 * ResultsViewDefaults.subheadingVerticalMargin)
                
                customConstraints.append(contentsOf: [labelCenterYConstraints, subheadingTopConstraint, dateTopConstraint])
                customConstraints.append(contentsOf: labelHorizontalConstraints)
                customConstraints.append(contentsOf: subheadingHorizontalConstraints)
                customConstraints.append(contentsOf: dateHorizontalConstraints)
                customConstraints.append(contentsOf: [copiedCenterXConstraint, copiedBottomConstraint])
            }
        }
        
        if containerView.subviews.contains(dayContainer) && containerView.subviews.contains(isoContainer) && containerView.subviews.contains(countContainer)
        {
            let dayTopConstraint = NSLayoutConstraint(item: dayContainer, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0)
            let dayHeightConstraint = NSLayoutConstraint(item: dayContainer, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 0.5, constant: 0.0)
            let dayBottomConstraint = NSLayoutConstraint(item: dayContainer, attribute: .bottom, relatedBy: .equal, toItem: isoContainer, attribute: .top, multiplier: 1.0, constant: 0.0)
            let isoHeightConstraint = NSLayoutConstraint(item: isoContainer, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 0.25, constant: 0.0)
            let countTopConstraint = NSLayoutConstraint(item: countContainer, attribute: .top, relatedBy: .equal, toItem: isoContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let countBottomConstraint = NSLayoutConstraint(item: countContainer, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let dayHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[day]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["day":dayContainer])
            let isoHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[iso]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["iso":isoContainer])
            let countHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[count]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["count":countContainer])
            customConstraints.append(contentsOf: [dayTopConstraint, dayHeightConstraint, dayBottomConstraint, isoHeightConstraint, countTopConstraint, countBottomConstraint])
            customConstraints.append(contentsOf: dayHorizontalConstraints)
            customConstraints.append(contentsOf: isoHorizontalConstraints)
            customConstraints.append(contentsOf: countHorizontalConstraints)
        }
        
        if view.subviews.contains(containerView)
        {
            let topConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let bottomConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -1 * ParentViewDefaults.pickerHeaderHeight - daySpacing * 2.0)
            let leftConstraint = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
            let widthConstraint = NSLayoutConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0.0)
            customConstraints.append(contentsOf: [topConstraint, bottomConstraint, leftConstraint, widthConstraint])
        }
        
        view.addConstraints(customConstraints)
    }
}

// MARK: - Button Actions

extension ResultsViewController {
    /**
     Performs an action with a label is tapped
     - Returns: void
     */
    @objc func onTapLabel(recognizer:UITapGestureRecognizer)
    {
        guard let label = recognizer.view as? UILabel else { return }
        
        let pasteboard = UIPasteboard.general
        if let paste = label.text
        {
            pasteboard.string = paste
        }
        
        UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: {
            label.transform = CGAffineTransform(scaleX: ResultsViewDefaults.labelAnimationScale, y: ResultsViewDefaults.labelAnimationScale)
        }) { (completed:Bool) in
            UIView.animate(withDuration: ResultsDayViewDefaults.dayViewAnimationDuration / 2.0, animations: {
                label.transform = CGAffineTransform.identity
            }) { (completed:Bool) in
                
            }
        }
        
        if label == isoLabel
        {
            isoCopiedLabel.isHidden = false
            UIView.animate(withDuration: ResultsViewDefaults.copiedLabelAnimationDuration, animations: { [weak self] in
                self?.isoCopiedLabel.alpha = 0.0
                }, completion: { [weak self] (completed:Bool) in
                    self?.isoCopiedLabel.isHidden = true
                    self?.isoCopiedLabel.alpha = 1.0
            })
        }
        
        if label == countLabel
        {
            countCopiedLabel.isHidden = false
            UIView.animate(withDuration: ResultsViewDefaults.copiedLabelAnimationDuration, animations: { [weak self] in
                self?.countCopiedLabel.alpha = 0.0
                }, completion: { [weak self] (completed:Bool) in
                    self?.countCopiedLabel.isHidden = true
                    self?.countCopiedLabel.alpha = 1.0
            })
        }
    }
}
