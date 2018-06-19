//
//  SummaryType.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import CoreData

/// Summary types for the population query data
enum SummaryType : String {
    case above =    "above"
    case average =  "average"
    case maximum =  "maximum"
    case minimum =  "minumum"
    
    /**
     Fetches the summary text from the persistent container
     - parameter container: An NSPersistentContainer referencing the population query data
     - Returns: a String of the summary text
     */
    func summary(from container:NSPersistentContainer)->String {
        return SummaryFormatter.summary(of:self, in:container)
    }
    
    /**
     Returns the function string for an NSFetchRequest that calculates the SummaryType
     - Returns: a string of the desired calculation function
     */
    func calculation()->String {
        switch self {
        case .above:
            return "sum:"
        case .average:
            return "average:"
        case .maximum:
            return "max:"
        case .minimum:
            return "min:"
        }
    }
}


