# Toy iOS Apps

The Toy iOS Apps repo contains a collection of iOS apps demonstrating proficiency in application design and development skills.  These apps generally began as no more than a day of work for past code interviews, and they have been updated with no more than one additional day to iterate and clean in response to feedback.

## TimeTurner

TimeTurner is designed to allow the user to input a date and output the following information:
- The day of the selected date (Monday, Tuesday...)
- The selected date in ISO8601 format
- The numerical difference in days, between the selected date and today's date

The TimeTurner project demonstrates:
- Model View Controller design pattern
- Parent and child view controllers
- Xib-less AutoLayout custom constraints
- UIView animations
- UINavigationController using naviation item appearances
- Usage of UIActivityViewController, UITableViewController, UIDatePicker
- Usage of UserDefaults, Locale, DateFormatter, NumberFormatter, NotificationCenter
- Unit tests using XCTest
- XCode inline documentation


## PopulationQuery

PopulationQuery is designed to fetch a raw JSON blob containing city population data and calculate the following:
- The set of states with populations above 10 million residents
- The average city population by state
- The largest and smallest city populations for each state

The PopulationQuery project demonstrates:
- Model View View Model design pattern
- Network fetching and local cacheing using URLSession
- JSON parsing into object containers
- CoreData storage, fetching, and summary calculations using NSPredicate and NSExpression
- Error handling using throws and NS_ERROR_ENUM
- Non-fatal error reporting to Bugsnag
- Usage of DispatchQueue
- Usage of interface builder
- Usage of cocoapods-keys to hide API keys
- Unit tests using XCTest and OCMock


## CUITouchTarget

CUITouchTarget is designed to intercept the touches from a UIViewController and send those to an Objective C++ app that detects a double tap gesture.  The project demostrates:
- Usage of Objective C++
- Calculation of a double tap gesture
