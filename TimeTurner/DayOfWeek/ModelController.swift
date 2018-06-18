//
//  ResultsModel.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import UIKit

/// Struct holding strings for model notification names
struct ModelNotification {
    static let modelDidUpdate = "kNotitificationModelDidUpdate"
    static let localeDidUpdate = "kNotificationLocaleDidUpdate"
}

class ModelController
{
    /// The current picker date
    /// Refreshes the model with the stored locale when updated
    var pickerDate:Date = Date()
    {
        didSet{
            refreshLocale()
        }
    }
    
    /// The selected day index, where 0 is Monday and 6 is Saturday
    var selectedDay:Int = -1
    
    // The last selected day index
    var lastSelectedDay:Int = -1
    
    /// The picker's title string
    var pickerTitle = "Choose a date"

    /// The subheading's title string
    let daySubheadingTitle = "Day of the week"

    /// The ISO title string
    var isoTitle = ""
    
    /// The count title string
    var countTitle = ""
    
    /// The count subheading title string
    let countSubheadingTitle = "days from"
    
    /// The count date title string
    var countDateTitle = ""

    /// A flag to indicate if a date has been selected
    var didChooseDate:Bool = false
    
    /// The title date formatter
    private var dateTitleFormatter = DateFormatter()
    
    /// The interval date formatter
    private var dateIntervalFormatter = DateIntervalFormatter()
    
    deinit {
        deregisterForNotifications()
    }
    
    init()
    {
        let locale = Settings.storedLocale()
        configureFormatters(for: locale)
        registerForNotifications()
    }
    
    /**
     Updates the picker date with the given date or refreshes the model if the date is nil
     - parameter date: the selected date
     - Returns: void
     */
    func update(date:Date)
    {
        pickerDate = date
    }
    
    /**
     Creates a string for sharing the ISO 8601 calculation
     - parameter isoTitle: ISO title string
     - parameter countDateTitle: date title
     - parameter countTitle: count title
     - Returns:  a combined string
     */
    func sharingText(isoTitle:String, countDateTitle:String, countTitle:String)->String
    {
        return "ISO 8601:\t\(isoTitle)\nDays from \(countDateTitle):\t\(countTitle)"
    }
}

private extension ModelController {
    /**
     Refreshes the model for the stored locale
     - Returns: void
     */
    func refreshLocale(with userDefaults:UserDefaults = UserDefaults.standard) {
        let locale = Settings.storedLocale(with: userDefaults)
        refreshModel(for: locale)
    }
    
    /**
     Refreshes the model for a given locale.  Posts a modelDidUpdate notification when complete.
     - parameter locale: Locale used to refresh the model
     - Returns: void
     */
    func refreshModel(for locale:Locale, with userDefaults:UserDefaults = UserDefaults.standard)
    {
        configureFormatters(for: locale, with:userDefaults)
        selectedDay = currentSelectedDay()
        pickerTitle = currentPickerTitle()
        isoTitle = currentIsoTitle(for: locale)
        countTitle = currentCountTitle(for: locale)
        countDateTitle = currentDateTitle()
        NotificationCenter.default.post(name: Notification.Name.init(ModelNotification.modelDidUpdate), object: nil)
    }

    /**
     Configures the title and interval date formatters
     - Returns: void
     */
    func configureFormatters(for locale:Locale, with userDefaults:UserDefaults = UserDefaults.standard)
    {
        dateTitleFormatter = DateFormatter()
        dateTitleFormatter.locale = locale
        dateTitleFormatter.dateStyle = .medium
        dateTitleFormatter.timeStyle = Settings.shouldShowTime(with:userDefaults) ? .medium : .none
        
        dateIntervalFormatter.locale = locale
        dateIntervalFormatter.dateStyle = .short
        dateIntervalFormatter.timeStyle = .none
    }
    
    /**
     Returns the currently selected day and updates the last selected day
     - Returns: an index of the currently selected day
     */
    func currentSelectedDay()->Int
    {
        guard let day = pickerDate.dayNumberOfWeek() else {
            return selectedDay
        }
        lastSelectedDay = selectedDay
        return day - 1
    }
    

    /**
     Returns the picker title if a date has been selected
     - Returns: a string of the picker title
     */
    func currentPickerTitle()->String
    {
        if didChooseDate == false { return pickerTitle }
        return dateTitleFormatter.string(from: pickerDate)
    }
    
    /**
     Returns the ISO title string for the given locale
     - parameter locale: the locale used to update the title
     - Returns: void
     */
    func currentIsoTitle(for locale:Locale)->String
    {
        if #available(iOS 10, *)
        {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.timeZone = Calendar.current.timeZone
            return isoFormatter.string(from: pickerDate)
        }
        else
        {
            return pickerDate.iso8601(for: locale)
        }
    }
    
    /**
     Updates the count title string for the given locale
     - parameter locale: the locale used to update the title
     - Returns: void
     */
    func currentCountTitle(for locale:Locale)->String
    {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.locale = locale
        formatter.numberStyle = .decimal
        let countDays = Date.daysFromToday(date:pickerDate)
        if let countString = formatter.string(from: NSNumber(value:countDays))
        {
            return countString
        }
        else
        {
            return "\(countDays)"
        }
        
    }
    
    /**
     Updates the date title string
     - Returns: the date title string
     */
    func currentDateTitle()->String{
        return dateIntervalFormatter.string(from: Date(), to: pickerDate)
    }
    
}

// MARK: - Notifications

extension ModelController {
    
    /**
     Registers for notifications
     - Returns: void
     */
    func registerForNotifications() {
        deregisterForNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onLocaleDidUpdateNotification(notification:)), name: NSNotification.Name.init(ModelNotification.localeDidUpdate), object: nil)
    }
    
    /**
     Deregisters for notifications
     - Returns: void
     */
    func deregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Performs an action when the locale did update notification is received
     - Returns: void
     */
    @objc func onLocaleDidUpdateNotification(notification:Notification) {
        refreshLocale()
    }
}
