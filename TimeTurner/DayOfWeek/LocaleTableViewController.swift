//
//  LocaleTableViewController.swift
//  TimeTurner
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import UIKit


class LocaleTableViewController: UITableViewController {
    
    /// The parent model delegate used to check and update the model
    weak var modelDelegate:ParentModelDelegate?
    
    /// The table data source of an array of (String, Locale)
    var tableDataSource = [(String,Locale)]()

    /// The table cell identifier
    static let cellIdentifer = "localeCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        buildNavigationBar()
        buildDataSource()
    }
    
    /**
     Builds the navigation bar items
     - Returns: void
     */
    func buildNavigationBar()
    {
        let restoreBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action:#selector(onTapRestore))
        navigationItem.rightBarButtonItem = restoreBarButtonItem
    }
    
    /**
     Builds the data source for the table view from the device's available locale identifiers
     - Returns: void
     */
    func buildDataSource()
    {
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: LocaleTableViewController.cellIdentifer)
        
        let identifiers = Locale.availableIdentifiers
        for ident in identifiers
        {
            let locale = Locale(identifier: ident)
            let nsLocale = locale as NSLocale

            guard let countryCode = nsLocale.object(forKey: NSLocale.Key.countryCode) as? String,
                let country = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value:countryCode) else { continue }
            
            let displayName = country
            
            tableDataSource.append((displayName, locale))
        }
        
        tableDataSource.sort { (first:(String, Locale), check:(String, Locale)) -> Bool in
            return first.0 < check.0
        }        
    }
    
// MARK: - Table view delegate and data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard tableDataSource.count > indexPath.item else { return UITableViewCell() }

        let tuple = tableDataSource[indexPath.item]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: LocaleTableViewController.cellIdentifer)
        cell.textLabel?.text = tuple.0
        
        let locale = Locale(identifier: tuple.1.identifier)
        
        let storedLocale = Settings.storedLocale()
        if locale.identifier == storedLocale.identifier
        {
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            cell.contentView.backgroundColor = view.tintColor
        }
        else
        {
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.darkGray
            cell.contentView.backgroundColor = UIColor.white
        }
        
        let nsLocale = locale as NSLocale

        guard let languageCode = nsLocale.object(forKey: NSLocale.Key.countryCode) as? String,
            let language = (locale as NSLocale).displayName(forKey: NSLocale.Key.languageCode, value:languageCode)  else {
                cell.detailTextLabel?.text = "\"" + locale.identifier + "\""
            return cell
        }
        
        cell.detailTextLabel?.text = language + " , \"" + locale.identifier + "\""

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard tableDataSource.count > indexPath.item else { return }
        
        let tuple = tableDataSource[indexPath.item]

        Settings.updateStored(locale: tuple.1)
        
        navigationController!.popToRootViewController(animated: true)
    }
}

// MARK: - Button Actions

extension LocaleTableViewController {
    
    /**
     Peforms an action when the restore button is tapped
     - Returns: void
     */
    @objc func onTapRestore()
    {
        Settings.updateStored(locale: nil)
        navigationController!.popToRootViewController(animated: true)
    }
}
