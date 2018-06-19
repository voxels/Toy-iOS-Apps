//
//  Network.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation

/// A callback type for passing the fetched JSON data
typealias NetworkFetchCompletion = ([[String:Any]])->Void

/// A network manager class for fetching population data
class NetworkManager : NSObject {
    /// The URL for fetching the population query data
    static let sourceString = "http://media.mongodb.org/zips.json"
    
    /**
     Fetches population query data for cities from the given source URL string
     - parameter source: the URL string to fetch data from
     - parameter completion: the callback containing any parsed data
     - Returns: void
     */
    class func fetch(from source:String, using sessionConfiguration:URLSessionConfiguration = .default, with completion: @escaping NetworkFetchCompletion) {
        DispatchQueue.global().async {
            guard let url = URL(string: source) else {
                return
            }
            
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.downloadTask(with: url) { (location, response, error) in
                if let e = error {
                    ErrorHandler.report(error: e as NSError)
                } else {
                    guard let location = location,
                        let dataFromURL = NSData(contentsOf: location), let savedURL = NetworkManager.saveLocally(data: dataFromURL as Data), let savedData = NSData(contentsOf:savedURL) else { return }
                    
                    guard let rawString = NSString(data: savedData as Data, encoding: String.Encoding.utf8.rawValue) else { return }
                    
                    if let entries = LocalStoreParser.parse(response: rawString) {
                        completion(entries)
                    }
                }
            }
            task.resume()
        }
    }
    
    /**
     Saves a data blob locally
     - parameter data: the data to be saved locally
     - Returns: the URL of the saved data or nil if it cannot be saved
     */
    class func saveLocally(data:Data)->URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        guard let documentsDirectory = paths.first else { return nil }
        let savePath = "\(documentsDirectory)//\(UUID().uuidString)"
        let fileURL = URL(fileURLWithPath: savePath)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            assert( false, error.localizedDescription)
        }
        
        return nil
    }
}


