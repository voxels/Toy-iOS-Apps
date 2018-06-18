//
//  ParentViewController.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

/// A protocol for fetching the model controller from the Parent View Controller
protocol ParentModelDelegate : class {
    func modelController()->ModelController
}

/// Default values for the results view
struct ParentViewDefaults {
    static let parentNavigationItemTitle = "Time Turner"
    static let pickerHeaderHeight:CGFloat = 100.0
    static let pickerHeight:CGFloat = 150.0 + 44.0
    static let pickerHeaderDefaultText = "Choose a Date"
    static let pickerHeaderHorizontalMargin:CGFloat = 20.0
    static let pickerAnimationDuration:TimeInterval = 0.5
}

class ParentViewController: UIViewController, UIPickerViewDelegate {

    /// A model controller instance
    let model = ModelController()
    
    /// An array of custom constraints for auto layout
    var customConstraints = [NSLayoutConstraint]()
    
    /// The picker container top constraint
    var pickerContainerTopConstraint:NSLayoutConstraint?

    /// A results view controller instance
    let resultsViewController = ResultsViewController(nibName: nil, bundle: nil)

    /// The picker container view
    let pickerContainerView = UIView(frame: CGRect.zero)
    
    /// The picker header view
    let pickerHeaderView = UIView(frame: CGRect.zero)
    
    /// The picker view
    let pickerView = UIDatePicker(frame: CGRect.zero)
    
    // The picker header container view
    var pickerHeaderContainer = UIView(frame: CGRect.zero)
    
    /// The picker header button
    var pickerHeaderButton = UIButton(type: .custom)
    
    /// A flag for moving the picture
    var isMovingPicker = false
    
    /// Appearance attributes for the picker header
    let pickerHeaderLabelAttributes = [NSAttributedStringKey.font : UIFont.appFontTitle(), NSAttributedStringKey.foregroundColor : UIColor.appMagentaColor()]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure(model: model, with: Date())
        resultsViewController.modelDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        buildView()
    }
    
    /**
     Triggers the model to update with the given date
     - parameter model: the model controller
     - parameter date: the date to use for refresh
     - Returns: void
     */
    func configure(model:ModelController, with date:Date) {
        model.update(date:date)
    }
}
    

// MARK: - Build View Hierarchy
extension ParentViewController {
    
    /**
     Builds the view hierarchy and requests an autolayout update cycle
     - Returns: void
     */
    func buildView()
    {
        edgesForExtendedLayout = []

        configureNavigationBar(with:ParentViewDefaults.parentNavigationItemTitle)
        buildContentView(with:resultsViewController)
        view.addSubview(pickerContainerView)

        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    /**
     Constructs the button items and configures the navigation bar
     - parameter title: the navigation bar title string
     - Returns: void
     */
    func configureNavigationBar(with title:String)
    {
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onTapShare))
        let menuBarButtonItem = UIBarButtonItem(image: UIImage(named:"hamburger"), style: .plain, target: self, action: #selector(onTapMenu))
        navigationItem.leftBarButtonItem = menuBarButtonItem
        navigationItem.rightBarButtonItem = shareBarButtonItem
        navigationItem.title = title
    }
    
    /**
     Constructs the content view
     - Returns: void
     */
    func buildContentView(with viewController:ResultsViewController)
    {
        buildResultsView(with:viewController)
        buildPickerContainer()
    }
    
    /**
     Constructs the picker container view
     - Returns: void
     */
    func buildPickerContainer()
    {
        pickerContainerView.backgroundColor = UIColor.appLemonColor()
        pickerContainerView.translatesAutoresizingMaskIntoConstraints = false
        buildPickerLabelContainer()
        buildPicker()
    }
    
    /**
     Constructs the picker label view
     - Returns: void
     */
    func buildPickerLabelContainer()
    {
        pickerHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        pickerHeaderButton.translatesAutoresizingMaskIntoConstraints = false
        
        let introAttributedString = NSAttributedString(string: ParentViewDefaults.pickerHeaderDefaultText, attributes:pickerHeaderLabelAttributes)
        
        pickerHeaderButton.setAttributedTitle(introAttributedString, for: .normal)
        pickerHeaderButton.setAttributedTitle(introAttributedString, for: .highlighted)
        pickerHeaderButton.addTarget(self, action: #selector(onTapPickerHeaderButton), for: .touchUpInside)
        pickerHeaderButton.titleLabel?.numberOfLines = 0
        pickerHeaderButton.titleLabel?.adjustsFontSizeToFitWidth = true
        pickerHeaderButton.titleLabel?.textAlignment = .center
        pickerHeaderContainer.addSubview(pickerHeaderButton)
        
        pickerContainerView.addSubview(pickerHeaderContainer)
    }
    
    /**
     Constructs the picker view
     - Returns: void
     */
    func buildPicker()
    {
        pickerView.frame = CGRect(x: 0.0, y: ParentViewDefaults.pickerHeaderHeight + 44.0, width: view.bounds.size.width, height: ParentViewDefaults.pickerHeight - 44.0)
        pickerView.backgroundColor = UIColor.white
        pickerView.datePickerMode = .date
        pickerView.addTarget(self, action: #selector(onDateChange(sender:)), for: .valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: ParentViewDefaults.pickerHeaderHeight, width: view.bounds.size.width, height: 44.0))
        toolbar.barStyle = .default
        toolbar.backgroundColor = UIColor.white
        toolbar.tintColor = UIColor.appMagentaColor()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(togglePickerContainer))
        toolbar.items = [space, button]
        pickerContainerView.addSubview(toolbar)
        pickerContainerView.addSubview(pickerView)
    }
    
    /**
     Constructs the results view
     - Returns: void
     */
    func buildResultsView(with viewController:ResultsViewController)
    {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
}
        
// MARK: - Autolayout Constraints
extension ParentViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if customConstraints.count > 0
        {
            view.removeConstraints(customConstraints)
            customConstraints.removeAll()
        }
        
        if view.subviews.contains(pickerContainerView)
        {
            let pickerHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[pickerContainer]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["pickerContainer":pickerContainerView])
            pickerContainerTopConstraint = NSLayoutConstraint(item: pickerContainerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -1 * ParentViewDefaults.pickerHeaderHeight)
            let pickerContainerHeightConstraint = NSLayoutConstraint(item: pickerContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ParentViewDefaults.pickerHeaderHeight + ParentViewDefaults.pickerHeight)
            customConstraints.append(contentsOf:pickerHorizontalConstraints)
            customConstraints.append(pickerContainerTopConstraint!)
            customConstraints.append(pickerContainerHeightConstraint)
        }
        
        if view.subviews.contains(resultsViewController.view)
        {
            let resultsHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[resultsView]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["resultsView": resultsViewController.view])
            let resultsVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[resultsView]|", options: NSLayoutFormatOptions.init(rawValue:0), metrics: nil, views: ["resultsView":resultsViewController.view])
            
            customConstraints.append(contentsOf:resultsHorizontalConstraints)
            customConstraints.append(contentsOf:resultsVerticalConstraints)
        }
        
        if pickerContainerView.subviews.contains(pickerHeaderContainer)
        {
            if pickerHeaderContainer.subviews.contains(pickerHeaderButton)
            {
                let centerXConstraint = NSLayoutConstraint(item: pickerHeaderButton, attribute: .centerX, relatedBy: .equal, toItem: pickerHeaderContainer, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                let centerYConstraint = NSLayoutConstraint(item: pickerHeaderButton, attribute: .centerY, relatedBy: .equal, toItem: pickerHeaderContainer, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                let pickerWidthConstraint = NSLayoutConstraint(item: pickerHeaderButton, attribute: .width, relatedBy: .equal, toItem: pickerContainerView, attribute: .width, multiplier: 1.0, constant: -ParentViewDefaults.pickerHeaderHorizontalMargin * 2.0)
                
                customConstraints.append(contentsOf:[centerXConstraint, centerYConstraint, pickerWidthConstraint])
            }
            
            let topConstraint = NSLayoutConstraint(item: pickerHeaderContainer, attribute: .top, relatedBy: .equal, toItem: pickerContainerView, attribute: .top, multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: pickerHeaderContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ParentViewDefaults.pickerHeaderHeight)
            let leftConstraint = NSLayoutConstraint(item: pickerHeaderContainer, attribute: .left, relatedBy: .equal, toItem: pickerContainerView, attribute: .left, multiplier: 1.0, constant: 0.0)
            let widthConstraint = NSLayoutConstraint(item: pickerHeaderContainer, attribute: .width, relatedBy: .equal, toItem: pickerContainerView, attribute: .width, multiplier: 1.0, constant: 0.0)
            customConstraints.append(contentsOf:[topConstraint, heightConstraint, leftConstraint, widthConstraint])
        }
        
        // Date picker frame is set manually
        
        view.addConstraints(customConstraints)
    }
}


// MARK: - Button Actions

extension ParentViewController {
    
    @objc func onTapShare()
    {
        let sharingText = model.sharingText(isoTitle: model.isoTitle, countDateTitle: model.countDateTitle, countTitle: model.countTitle)
        let activityViewController = UIActivityViewController(activityItems: [sharingText], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks, .postToFlickr, .postToVimeo, .saveToCameraRoll]
        navigationController?.present(activityViewController, animated: true, completion: {
            
        })
    }
    
    @objc func onTapMenu()
    {
        let menuViewController = MenuViewController(nibName: nil, bundle: nil)
        navigationController?.pushViewController(menuViewController, animated: false)
    }
    
    @objc func onTapPickerHeaderButton()
    {
        togglePickerContainer()
    }
    
    @objc func onDateChange(sender:UIDatePicker)
    {
        #if DEBUG
            print(sender.date)
        #endif
    }
    
    @objc func togglePickerContainer()
    {
        if isMovingPicker
        {
            return
        }
        
        isMovingPicker = true
        
        if pickerContainerTopConstraint?.constant == -ParentViewDefaults.pickerHeaderHeight
        {
            pickerContainerTopConstraint?.constant = -1 * (ParentViewDefaults.pickerHeaderHeight + ParentViewDefaults.pickerHeight)
        }
        else
        {
            pickerContainerTopConstraint?.constant = -1 * (ParentViewDefaults.pickerHeaderHeight)
            model.didChooseDate = true
            let date = Settings.shouldShowTime() ? pickerView.date : Calendar.current.startOfDay(for: pickerView.date)
            model.update(date:date)
        }
        
        UIView.animate(withDuration: ParentViewDefaults.pickerAnimationDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.05, options: .curveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] (completed:Bool) in
            self?.isMovingPicker = false
        }
    }
    
    // MARK: - Model
    
    @objc func modelDidUpdate()
    {
        pickerView.locale = Settings.storedLocale()
        updatePickerLabel()
    }
    
    func updatePickerLabel()
    {
        let attribTitle = NSAttributedString(string: model.pickerTitle, attributes: pickerHeaderLabelAttributes)
        pickerHeaderButton.setAttributedTitle(attribTitle, for: .normal)
        pickerHeaderButton.setAttributedTitle(attribTitle, for: .highlighted)
    }
}

// MARK: - Notifications
extension ParentViewController {
    func deregisterForNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(ModelNotification.modelDidUpdate), object: nil)
    }
    
    func registerForNotifications()
    {
        deregisterForNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(modelDidUpdate), name: Notification.Name.init(ModelNotification.modelDidUpdate), object: nil)
    }
}

extension ParentViewController : ParentModelDelegate {
    func modelController()->ModelController {
        return model
    }
}
