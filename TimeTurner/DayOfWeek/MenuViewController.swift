//
//  MenuViewController.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

/// Default settings of the menu view
struct MenuViewDefaults {
    static let tableViewCellIdentifier = "cell"
    static let versionViewHeight:CGFloat = 44.0
}

/// Titles for the menu cells
enum MenuCellTitles : String {
    case locale = "Locale"
    case donate = "Donate"
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// An array of custom constraints for auto layout
    var customConstraints = [NSLayoutConstraint]()
    
    /// The table view
    var tableView:UITableView?
    
    /// The table view data source
    var tableDataSource = [String]()
    
    /// The version view
    var versionView:UIView = UIView(frame: CGRect.zero)
    
    /// The version label
    var versionLabel:UILabel = UILabel(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViews()
    }
}

// MARK: - Build View Hierarchy

extension MenuViewController {
    
    /**
     Builds the views for the controller and requests an autolayout update cycle
     - Returns: void
     */
    func buildViews()
    {
        tableDataSource = buildTableViewDataSource()
        tableView = buildTableView()
        configureVersionView(with:versionLabelString(), font:UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.thin))
        
        guard let table = tableView else {
            assert( false, "No table found for menu")
        }
        
        view.addSubview(table)
        versionView.addSubview(versionLabel)
        view.addSubview(versionView)
        
        view.setNeedsUpdateConstraints()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    /**
     Constructs the table view data source
     - Returns: a string array of the data source
     */
    func buildTableViewDataSource()->[String]
    {
        var dataSource = [String]()
        dataSource.append(MenuCellTitles.locale.rawValue)
        dataSource.append(MenuCellTitles.donate.rawValue)
        return dataSource
    }
    
    /**
     Constructs the table view
     - Returns: a UITableView
     */
    func buildTableView()->UITableView
    {
        let newTableView = UITableView(frame: CGRect.zero, style: .plain)
        newTableView.translatesAutoresizingMaskIntoConstraints = false
        newTableView.delegate = self
        newTableView.dataSource = self
        newTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: MenuViewDefaults.tableViewCellIdentifier)
        return newTableView
    }
}

// MARK: UITableView data source and delegate

extension MenuViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MenuViewDefaults.tableViewCellIdentifier)
        {
            guard tableDataSource.count > indexPath.item else { return UITableViewCell() }
            let title = tableDataSource[indexPath.item]
            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        assert( false, "Should not reach this point")
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.item
        {
        case 0:
            pushLocaleTableView()
        case 1:
            showDonationDialog()
        default:
            print("found unknown case")
        }
    }
}

// MARK: - Configure Version View

extension MenuViewController {
    
    /**
     Configures the version view with the version label
     - parameter title: the text string
     - parameter font: the label font
     - Returns: void
     */
    func configureVersionView(with title:String, font:UIFont)
    {
        versionView.translatesAutoresizingMaskIntoConstraints = false
        configureVersionLabel(with:title, font:font)
    }
    
    /**
    Configures the version label with the title
     - parameter title: the text string
     - parameter font: the label font
     - Returns: void
    */
    func configureVersionLabel(with title:String, font:UIFont) {
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.text = title
        versionLabel.font = font
    }
    
    /**
    Constructs the version label string
     - Returns: a combined string of the version and build
    */
    func versionLabelString()->String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
        return "\(version)\t(\(build))"
    }
}

// MARK: - Autolayout Constraints

extension MenuViewController {
    
    override func updateViewConstraints() {
        super.updateViewConstraints()

        if customConstraints.count > 0
        {
            view.removeConstraints(customConstraints)
            customConstraints.removeAll()
        }
        
        if view.subviews.contains(versionView)
        {
            if versionView.subviews.contains(versionLabel)
            {
                let centerXConstraint = NSLayoutConstraint(item: versionLabel, attribute: .centerX, relatedBy: .equal, toItem: versionView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
                let centerYConstraint = NSLayoutConstraint(item: versionLabel, attribute: .centerY, relatedBy: .equal, toItem: versionView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
                customConstraints.append(contentsOf: [centerXConstraint, centerYConstraint])
            }
            
            let bottomConstraint = NSLayoutConstraint(item: versionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let heightConstraint = NSLayoutConstraint(item: versionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: MenuViewDefaults.versionViewHeight)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[versionView]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["versionView":versionView])
            
            customConstraints.append(contentsOf: [bottomConstraint, heightConstraint])
            customConstraints.append(contentsOf: horizontalConstraints)
        }
        
        guard tableView != nil else { return }
        
        if view.subviews.contains(tableView!)
        {
            let topConstraint = NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let bottomConstraint = NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: versionView, attribute: .top, multiplier: 1.0, constant: 0.0)
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: ["tableView":tableView!])
            customConstraints.append(contentsOf: [topConstraint, bottomConstraint])
            customConstraints.append(contentsOf: horizontalConstraints)
        }
        
        view.addConstraints(customConstraints)
    }
}
    
// MARK: - Button Actions

extension MenuViewController {
    /**
     Pushes a new local table view instance onto the navigation controller stack
     - Returns: void
     */
    func pushLocaleTableView()
    {
        let localeTableViewController = LocaleTableViewController(nibName: nil, bundle: nil)
        navigationController?.pushViewController(localeTableViewController, animated: true)
    }
    
    /**
     Shows the donation dialog alert controller
     - Returns: void
     */
    func showDonationDialog()
    {
        let alertController = UIAlertController(title: "Donate", message: "If you are enjoying TimeTurner, please consider donating to the Electronic Frontier Foundation.", preferredStyle: .alert)
        
        let donateAction = UIAlertAction(title: "Donate to EFF", style: .default) { (action:UIAlertAction) in
            UIApplication.shared.openURL(URL(string: "http://eff.org")!)
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            // Do nothing
        }
        
        alertController.addAction(donateAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true) {
            
        }
    }
}
