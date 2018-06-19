//
//  LocalStoreParser.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import CoreData

/// Keys referencing the city data in the raw fetched JSON blob
enum LocalStoreParserCityKey : String {
    case ident = "_id"
    case state = "state"
    case city = "city"
    case location = "loc"
    case population = "pop"
}

/// Keys referencing the state data in the raw fetched JSON blob
enum LocalStoreParserStateKey : String {
    case state = "state"
    case population = "population"
}

/// Struct of parameters used to store zip code data
struct ZipCodeParameters {
    var ident:String
    var state:String
    var city:String
    var latitude:Double
    var longitude:Double
    var population:Double
}

/// Struct of parameters used to store city data
struct CityParameters : Hashable {
    var name:String
    var state:String
    var population:Double
    
    var hashValue: Int {
        return name.hashValue
    }
    
    static func ==(lhs:CityParameters, rhs:CityParameters)->Bool {
        return lhs.state == rhs.state && lhs.name == rhs.name
    }
}

/// Struct of parameters used to store state data
struct StateParameters {
    var abbreviation : String
    var population : Double
}

/// A completion type for callback requesting parsed data when parsing is completed
typealias ParsingCompletion = (Set<CityParameters>, [ZipCodeParameters])->Void

/// The parsing class for local store data
@objc(LocalStoreParser)
@objcMembers class LocalStoreParser : NSObject {
    
    /**
     Parses the JSON blob String response into an array of entries
     - Returns: a [[String:Any]] if the response can be parsed or nil if it fails
     */
    class func parse(response:NSString)->[[String:Any]]? {
        var parsed = [[String:Any]]()
        let entries = response.components(separatedBy: .newlines)
        if entries.count > 0 {
            for entry in entries {
                if entry.count == 0 {
                    continue
                }
                
                if let data = entry.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                            parsed.append(json)
                        }
                    } catch let e as NSError {
                        assert(false, e.localizedDescription)
                        ErrorHandler.report(error: e)
                    }
                }
            }
        }
        
        if parsed.count > 0 {
            return parsed
        }
        else {
            let error = ErrorHandler.error(with: InternalError.parsingErrorCode.rawValue, localizedDescription: "Could not find any entries in retrieved source")
            ErrorHandler.report(error: error)
        }
        
        return nil
    }
    
    /**
     Creates CityParameters and ZipCodeParameters from an array of raw data entires
     - parameter data: the raw array of dictionary entries
     - parameter completion: the ParsingCompletion callback passing back the parsed parameters
     */
    class func createParameters(with data:[[String:Any]], completion:ParsingCompletion) {
        
        var cityParameterSet = Set<CityParameters>()
        
        let zipCodeParameters = data.compactMap({ (dict) -> ZipCodeParameters? in
            
            if let zipParameters =
                LocalStoreParser.zipCodeParameters(from: dict) {
                var cityParameters = LocalStoreParser.cityParameters(from: zipParameters)
                
                if let index = cityParameterSet.index(of: cityParameters) {
                    let existing = cityParameterSet[index]
                    let cumulative = existing.population + zipParameters.population
                    let updateParameters = CityParameters(name:existing.name, state: existing.state, population: cumulative)
                    cityParameterSet.update(with: updateParameters)
                }
                else {
                    cityParameters.population = zipParameters.population
                    cityParameterSet.insert(cityParameters)
                }
                return zipParameters
            }
            
            return nil
        })
        
        completion(cityParameterSet, zipCodeParameters)
    }
}


// MARK: - Struct extraction

extension LocalStoreParser {
    
    /**
     Constructs CityParameters from ZipCodeParameters
     - parameter zipCode: the ZipCodeParameters containing the CityParameters data
     - Returns: a CityParameters struct extracted from the zip code data
     */
    class func cityParameters(from zipCode:ZipCodeParameters)->CityParameters {
        
        return CityParameters(name: zipCode.city, state: zipCode.state, population:0)
    }
    
    /**
     Constructs ZipCodeParameters from a raw JSON dictionary
     - parameter dict: the raw JSON dictionary of zip code data
     - Returns: a ZipCodeParameters struct or nil if the dictionary cannot be parsed
     */
    class func zipCodeParameters(from dict:[String:Any])->ZipCodeParameters? {
        
        guard let identity = dict[LocalStoreParserCityKey.ident.rawValue] as? String,
            let state = dict[LocalStoreParserCityKey.state.rawValue] as? String,
            let city = dict[LocalStoreParserCityKey.city.rawValue] as? String,
            let population = dict[LocalStoreParserCityKey.population.rawValue] as? Double,
            let location = dict[LocalStoreParserCityKey.location.rawValue] as? [Double],
            let latitude = location.first,
            let longitude = location.last
            else { return nil }
        
        return ZipCodeParameters(ident: identity, state: state, city: city, latitude: latitude, longitude: longitude, population: population)
    }
    
    /**
     Constructs StateParameters from a raw JSON dictionary
     - parameter dict: the raw JSON dictionary of zip code data
     - Returns: a StateParameters struct or nil if the dictionary cannot be parsed
     */
    class func stateParameters(from dict:[String:Any])->StateParameters? {
        guard let abbreviation = dict[CityKey.state.rawValue] as? String, let population = dict[CityKey.population.rawValue] as? Double else { return nil }
        return StateParameters(abbreviation: abbreviation, population: population)
    }
}
