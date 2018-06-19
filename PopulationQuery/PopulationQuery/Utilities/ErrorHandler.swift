//
//  ErrorHandler.swift
//  PopulationQuery
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

import Foundation
import Bugsnag

/// Error handling class sending non-fatal reports to analytics services
class ErrorHandler {

    /**
     Reports a non-fatal error to Bugsnag
     - parameter error: The nonfatal error
     - Returns: void
     */
    static func report(error:NSError) {
        Bugsnag.notifyError(error)
    }
    
    /**
     Constructs an NSError with the given code and description
     - parameter code: the nonfatal error code
     - parameter localizedDescription: the reason for the failure
     - Retruns: An NSError with an embedded userInfo dictionary containing the error description
     */
    static func error(with code:Int, localizedDescription:String )->NSError {
        return NSError(domain: AppErrorDomain, code: code, userInfo: ErrorHandler.description(for: localizedDescription))
    }
}

private extension ErrorHandler {
    /**
     Constructs an NSError user info dictionary containing a localized description for the given reason
     - parameter localizedDescription: the reason given for the error's localized description
     - Returns: a [String:Any] of the error's localized description
     */
    static func description(for localizedDescription:String)->[String:Any] {
        return [NSLocalizedDescriptionKey : localizedDescription]
    }
}
