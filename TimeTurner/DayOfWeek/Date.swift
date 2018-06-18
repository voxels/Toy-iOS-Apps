//
//  Date.swift
//  DayOfWeek
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation

extension Date
{
    /**
     Creates the ISO 8601 string from the date instance
     - parameter locale: Locale used to create the string
     - Returns: An ISO 8601 string of the date instance
     */
    func iso8601(for locale:Locale)->String {
        return DateFormatter.iso8601Formatter(for: locale).string(from: self)
    }
    
    /**
     Calculates the day number of the week
     
     [Stack Overflow Reference](http://stackoverflow.com/questions/25533147/get-day-of-week-using-nsdate-swift)
     
     - Returns: The weekday index integer
     */
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    /**
     Creates the day abbreviation for a given index and locale
     - parameter index: Weekday index
     - parameter locale: Locale used to create the abbreviation
     - Returns: A string of the day name's abbreviation
     */
    static func dayAbbreviation(index:Int, for locale:Locale)->String
    {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = locale
        formatter.dateFormat = "EEE"
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = index + 1
        if let firstday = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
        {
            let retval = formatter.string(from: firstday)
            return retval
        }
        
        assert( false, "should not reach this point")
        return ""
    }
    
    /**
     Calculates the number of days from today
     - parameter date: the date used to calculate the number of days from today
     - Returns: An integer of the number of days from today
     */
    static func daysFromToday(date: Date) -> Int {
        let retval = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date))
        guard retval.day != nil else { return 0 }
        return retval.day!
    }
}
