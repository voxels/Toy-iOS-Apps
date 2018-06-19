//
//  SummaryFormatter.swift
//  PopulationQuery
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

import Foundation
import CoreData

/// A formatting object that returns summary text for a population query
struct SummaryFormatter {
    /**
     Constructs the summary text for a given SummaryType from an NSPersistentContainer
     - parameter type: The type of summary requested
     - parameter container: an NSPersistentContainer referencing the population query data
     - Returns: a String of the summary content
     */
    static func summary(of type:SummaryType, in container:NSPersistentContainer)->String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        
        var prefix = ""
        var list = ""
        let suffix = "\n"
        
        let states = results( of:type, from: container)
        
        switch type {
        case .above:
            prefix = "The following states have populations in excess of 10 million:\n"
            for dict in states {
                guard let state = LocalStoreParser.stateParameters(from: dict) else { continue }
                list.append("\t\(state.abbreviation)\t:\t\(formatter.string(from:state.population as NSNumber)!)\n")
            }
        case .average:
            prefix = "States have average city population size of:\n"
            for dict in states {
                guard let state = LocalStoreParser.stateParameters(from: dict) else { continue }
                list.append("\t\(state.abbreviation)\t:\t\(formatter.string(from:state.population as NSNumber)!)\n")
            }
        case .maximum:
            fallthrough
        case .minimum:
            prefix = "The biggest and smallest cities in each state are:\n"
            for dict in states {
                guard let state = dict[CityKey.state.rawValue] as? String, let minCity = dict["min"] as? City, let minCityName = minCity.city, let maxCity = dict["max"] as? City, let maxCityName = maxCity.city else { continue }
                
                list.append("State: \(state):\n")
                list.append("\tLowest population city:\n")
                list.append("\t\(minCityName), \(formatter.string(from:minCity.population as NSNumber)!) residents\n\n")
                list.append("\tHighest population city:\n")
                list.append("\t\(maxCityName), \(formatter.string(from:maxCity.population as NSNumber)!) residents\n\n")
            }
        }
        
        return "\(prefix)\n\(list)\n\(suffix)"
    }
}

private extension SummaryFormatter {
    /**
     Constructs a fetch request for a given summary type
     - parameter type: the SummaryType of the desired calculation
     - Returns: an NSFetchRequest constructed with the calulation parameters
     */
    static func fetchRequest(of type:SummaryType)->NSFetchRequest<NSFetchRequestResult> {
        return LocalStoreManager.cityPopulationSummaryFetch(with: type.calculation())
    }
    
    /**
     Constructs the results of a fetch request for a given SummaryType
     - parameter type: the SummaryType of the desired calculation
     - parameter container: the NSPersistentContainer referencing the population query data
     - Returns: an [[String:Any]] of results for the SummaryType calculation
     */
    static func results(of type:SummaryType, from container:NSPersistentContainer)->[[String:Any]] {
        var results = [[String:Any]]()
        
        switch type {
        case .above:
            do {
                if let rawStates = try LocalStoreManager.results(from: fetchRequest(of:type), in:container) {
                    results = rawStates.filter({ (dict) -> Bool in
                        if let sum = dict[LocalStoreParserStateKey.population.rawValue] as? Int, sum > 10000000 {
                            return true
                        }
                        return false
                    })
                }
            } catch let e as NSError {
                ErrorHandler.report(error: e)
            }
        case .average:
            do {
                if let rawStates = try LocalStoreManager.results(from: fetchRequest(of:type), in:container) {
                    results = rawStates
                }
            } catch let e as NSError {
                ErrorHandler.report(error: e)
            }
        case .maximum:
            fallthrough
        case .minimum:
            do {
                if let maxCities = try LocalStoreManager.results(from: fetchRequest(of:.maximum), in: container) {
                    do {
                        if let minCities = try LocalStoreManager.results(from: fetchRequest(of: .minimum), in: container) {
                            
                            var combined = [String:[String:City]]()
                            
                            for dict in maxCities {
                                guard let objectID = dict["objectID"] as? NSManagedObjectID, let city = container.viewContext.object(with: objectID) as? City, let state = city.state else {
                                    let error = ErrorHandler.error(with: InternalError.parsingErrorCode.rawValue, localizedDescription: "Failed to parse dictionary: \(dict)")
                                    ErrorHandler.report(error: error)
                                    continue
                                }
                                combined[state] = ["max":city]
                            }
                            
                            for dict in minCities {
                                guard let objectID = dict["objectID"] as? NSManagedObjectID, let city = container.viewContext.object(with: objectID) as? City, let state = city.state else {
                                    let error = ErrorHandler.error(with: InternalError.parsingErrorCode.rawValue, localizedDescription: "Failed to parse dictionary: \(dict)")
                                    ErrorHandler.report(error: error)
                                    continue
                                }
                                
                                if let existing = combined[state] {
                                    var update = existing
                                    update["min"] = city
                                    combined[state] = update
                                } else {
                                    combined[state] = ["min":city]
                                }
                            }
                            
                            
                            var formatted = [[String:Any]]()
                            
                            for key in combined.keys.sorted() {
                                if let value = combined[key], let minCity = value["min"], let maxCity = value["max"] {
                                    let final:[String:Any] = [CityKey.state.rawValue:key, "min":minCity, "max":maxCity]
                                    formatted.append(final)
                                }
                            }
                            
                            results = formatted
                        }
                    } catch let e as NSError {
                        ErrorHandler.report(error: e)
                    }
                }
            } catch let e as NSError {
                ErrorHandler.report(error: e)
            }
        }
        
        return results
    }
}
