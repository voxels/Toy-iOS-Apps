//
//  DateFormatter.swift
//  TimeTurner
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation

extension DateFormatter {
    /**
     Creates an ISO 8601 date formatter
     
     [Date Formatter StackOverflow Post](http://stackoverflow.com/questions/28016578/swift-how-to-create-a-date-time-stamp-and-format-as-iso-8601-rfc-3339-utc-tim)
     
     - parameter locale: Locale used to create the formatter
     - Returns: An ISO 8601 date formatter
     */
    static func iso8601Formatter(for locale:Locale) -> DateFormatter{
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = locale
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }
}
