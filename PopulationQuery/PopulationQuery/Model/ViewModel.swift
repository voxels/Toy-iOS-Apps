//
//  ViewModel.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import CoreData

/// Protocol providing a callback for model updates
@objc protocol ViewModelDelegate {
    func modelDidUpdate()
}

/// The View Model for a Main View Controller
@objc (ViewModel)
@objcMembers class ViewModel : NSObject {
    /// The model delegate
    var delegate:ViewModelDelegate?
    
    /// The local store manager used to access cached data
    private static let storeManager = LocalStoreManager()
    
    /**
     Refreshes a local store manager and calls the delegate callback when complete
     - parameter manager: a LocalStoreManager that fetches the results
     - Returns: void
     */
    func refresh(with manager:LocalStoreManager = ViewModel.storeManager) {
        manager.refresh { [weak self] in
            self?.delegate?.modelDidUpdate()
        }
    }
    
    /**
     Constructs the content string of results fetched from an NSPersistentContainer
     - parameter container: NSPersistentContainer referencing the expected summary type data
     - Returns: a String of the summary type results
     */
    func results(from container:NSPersistentContainer = ViewModel.storeManager.persistentContainer)->String {
        var results = ""
        
        results.append(SummaryType.above.summary(from:container))
        results.append(SummaryType.average.summary(from:container))
        results.append(SummaryType.maximum.summary(from:container))
        
        return results
    }
}


