//
//  Settings.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation

/// Enum for fetching the strings for stored user defaults
enum StoredSettings : String
{
    case time = "time"
    case locale = "locale"
}

class Settings
{
    /// Prefix string for user defaults storage
    static let appPrefix = "com.noisederived.dayofweek."

    /**
     Returns the user default for showing time
     - Returns: a boolean flag for showing time
     */
    static func shouldShowTime(with userDefaults:UserDefaults = UserDefaults.standard)->Bool
    {
        return userDefaults.bool(forKey: Settings.key(item: .time))
    }
    
    /**
     Updates the user defaults flag for showing time
     - parameter shouldStore: boolean flag for showing time
     - Returns: void
     */
    static func updateShowTime(shouldStore:Bool, with userDefaults:UserDefaults = UserDefaults.standard)
    {
        userDefaults.set(shouldStore, forKey: Settings.key(item: .time))
        userDefaults.synchronize()
    }
    
    /**
     Updates the user defaults identifier for the current locale
     - parameter locale: the locale used to cache the identifier
     - Returns: void
     */
    static func updateStored(locale:Locale? = nil, with userDefaults:UserDefaults = UserDefaults.standard)
    {
        if let l = locale {
            userDefaults.set(l.identifier, forKey: Settings.key(item: .locale))
        }
        else
        {
            userDefaults.removeObject(forKey: Settings.key(item: .locale))
        }
        
        userDefaults.synchronize()
        NotificationCenter.default.post(name: Notification.Name.init(ModelNotification.localeDidUpdate), object: nil)
    }
}

extension Settings {
    /**
     Returns the cached locale identifier
     - Returns: A string for the cached locale identifer, if found in user defaults
     */
    static func storedLocaleIdentifier(with userDefaults:UserDefaults = UserDefaults.standard)->String?
    {
        return userDefaults.value(forKey: Settings.key(item: .locale)) as? String
    }

    /**
     Returns a key for storing an item in user defaults
     - parameter item: the item being stored in the user defaults cache
     - Returns: A string key used to reference an item in user defaults
     */
    static func key(item:StoredSettings)->String
    {
        return Settings.appPrefix + item.rawValue
    }

    /**
     Returns a locale created from the stored locale identifier
     - Returns: A locale if an cached identifier is found or the current locale if none is found
     */
    static func storedLocale(with userDefaults:UserDefaults = UserDefaults.standard)->Locale
    {
        return Settings.storedLocaleIdentifier(with: userDefaults) != nil ? Locale(identifier: Settings.storedLocaleIdentifier(with: userDefaults)!) : Locale.autoupdatingCurrent
    }
}
