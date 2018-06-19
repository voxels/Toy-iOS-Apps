//
//  LocalStoreManager.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import Foundation
import CoreData

/// String keys used to parse and fetch data
enum CityKey : String {
    case city
    case state
    case population
}


/// Completion type for saving the local store NSManagedObjectContext
typealias SaveContextCompletion = ()->Void

/// A manager class used to operate the CoreData local store
@objc (LocalStoreManager)
@objcMembers class LocalStoreManager : NSObject {
    
    /// String key for a City entity
    static let cityEntityKey = "City"
    
    /// String key for a ZipCode entity
    static let zipCodeEntityKey = "ZipCode"
    
    /// Fetch request that fetches all cities
    let allCitiesRequest:NSFetchRequest<City> = NSFetchRequest(entityName: LocalStoreManager.cityEntityKey)
    
    /// Fetch request the fetches all zip codes
    let allZipCodesRequest:NSFetchRequest<ZipCode> = NSFetchRequest(entityName:LocalStoreManager.zipCodeEntityKey)

    /// A callback for saving the local store context
    var saveCompletion:SaveContextCompletion?
    
    deinit {
        deregisterForNotifications()
    }
    
    /// The persistent container refrencing the population query data model
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PopulationQuery")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                let errorDescription = "Error saving persistent store: \(error.localizedDescription)"
                assert( false, errorDescription )
                let error = ErrorHandler.error(with: InternalError.loadStoreErrorCode.rawValue, localizedDescription: errorDescription)
                ErrorHandler.report(error: error)
            }
        })
        return container
    }()
}


// MARK: - Fetch Operations

extension LocalStoreManager {
    
    /**
     Fetches the results from a given fetch request in a persistent container
     - parameter request: an NSFetchRequest of any type
     - parameter container: an NSPersistentContainer of any type
     - Returns: a [[String:Any]] of the fetch request results or nil if none are found
     */
    class func results(from request:NSFetchRequest<NSFetchRequestResult>, in container:NSPersistentContainer) throws ->[[String:Any]]? {
        do {
            if let results:Array<NSDictionary> = try container.viewContext.fetch(request) as? Array<NSDictionary>{
                return results as? [[String:Any]]
            }
        } catch {
            let errorDescription = "Error fetching request from container: \(error.localizedDescription)"
            assert( false, errorDescription )
            let error = ErrorHandler.error(with: InternalError.fetchStoreErrorCode.rawValue, localizedDescription: errorDescription)
            throw error
        }
        
        return nil
    }
    
    /**
     Fetches a zip code with the given object ID
     - parameter objectID: the managed object ID of the desired zip code
     - parameter container: the container referencing the zip code data
     - Returns: a ZipCode entity or nil if none is found
     */
    class func zipCode(with objectID:NSManagedObjectID, in container:NSPersistentContainer)->ZipCode? {
        return container.viewContext.object(with: objectID) as? ZipCode
    }

    /**
     Fetches a city with the given CityParameters
     - parameter parameters: the CityParameters of the desired city
     - parameter context: the managed object context containing the city data
     - Returns: a City entity or nil if none is found
     */
    class func city(with parameters:CityParameters, from context:NSManagedObjectContext)->City? {
        do {
            let city = try LocalStoreManager.city(with: parameters.name, in: parameters.state, from: context)
            return city
        } catch let e as NSError {
            ErrorHandler.report(error: e)
            return nil
        }
    }
    
    /**
     Fetches a city with the given CityParameters
     - parameter name: the name of the desired city
     - parameter state: the state of the desired city
     - parameter context: the managed object context containing the city data
     - Returns: a City entity or nil if none is found
     */
    class func city(with name:String, in state:String, from context:NSManagedObjectContext) throws -> City? {
        let request = NSFetchRequest<City>(entityName:LocalStoreManager.cityEntityKey)
        let namePredicate = NSPredicate(format: "city == %@", name)
        let statePredicate = NSPredicate(format: "state == %@", state)
        let compoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [namePredicate, statePredicate])
        request.predicate = compoundPredicate
        guard let results = try? context.fetch(request) else { return nil }
        
        if results.count > 1 {
            let error = ErrorHandler.error(with: InternalError.duplicateEntryErrorCode.rawValue, localizedDescription: "Error: Found more than one city with the same name")
            throw error
        }
        
        return results.first
    }
    
    /**
     Constructs an NSFetchRequest fo the city population summary
     - parameter calculation: the calculation string for the summary, such as: "sum:", "average:" etc.
     - Returns: An NSFetchRequest operating with the desired calculation function
     */
    class func cityPopulationSummaryFetch(with calculation:String)->NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: LocalStoreManager.cityEntityKey)
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = [CityKey.state.rawValue]
        request.resultType = .dictionaryResultType
        
        let selfExp = NSExpression(expressionType: .evaluatedObject)
        let selfDesc = NSExpressionDescription()
        selfDesc.expression = selfExp
        selfDesc.name = "objectID"
        selfDesc.expressionResultType = .objectIDAttributeType
        
        let keypathExp = NSExpression(forKeyPath: CityKey.population.rawValue)
        let maxExpression = NSExpression(forFunction: calculation, arguments: [keypathExp])
        let maxDesc = NSExpressionDescription()
        maxDesc.expression = maxExpression
        maxDesc.name = CityKey.population.rawValue
        maxDesc.expressionResultType = .doubleAttributeType
        request.propertiesToFetch = [CityKey.state.rawValue, maxDesc, selfDesc]
        return request
    }
}

// MARK: - Context Operations

extension LocalStoreManager {
    
    /**
     Refreshes the local store with a network fetch
     - parameter completion: a callback for execution when the network fetch is complete
     - Returns: void
     */
    func refresh(with completion: @escaping SaveContextCompletion) {
        saveCompletion = completion
        print("Fetching city data")
        NetworkManager.fetch(from: NetworkManager.sourceString) {[weak self] (data) in
            guard let zipCodes = self?.allZipCodesRequest as? NSFetchRequest<NSFetchRequestResult>, let cities = self?.allCitiesRequest as? NSFetchRequest<NSFetchRequestResult>, let container = self?.persistentContainer else { return }
            
            self?.replace(data: data, in: container, with:[zipCodes, cities])
        }
    }
    
}

private extension LocalStoreManager {
    /**
     Saves the NSManagedObjectContext
     - parameter context: the context to save
     - Throws: an NSError if the save cannot be completed
     - Returns: void
     */
    class func save(_ context:NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                throw nserror
            }
        }
    }

    /**
     Replaces the existing data model with an [[String:Any]] of population query data
     - parameter model: the model to update the local store with
     - parameter container: the persistent container referencing the population query data
     - parameter entities: the entities used to store the model
     - Returns: void
     */
    func replace(data model:[[String:Any]], in container:NSPersistentContainer, with entities:[NSFetchRequest<NSFetchRequestResult>]) {
        print("Clearing existing entries")
        clearCurrent(container, with:entities) {
            let context = container.newBackgroundContext()
            print("Adding new entries from \(model.count) rows")
            
            LocalStoreParser.createParameters(with: model, completion: { (cities, zipCodes) in
                print("Created \(cities.count) cities from \(zipCodes.count)")
                print("Storing model....")
                
                LocalStoreManager.insert(cities: cities, into: context)
                LocalStoreManager.insert(zipCodes: zipCodes, into: context)
                
                registerForNotification()
                
                do{
                    print("Saving context")
                    try LocalStoreManager.save(context)
                } catch let e as NSError {
                    ErrorHandler.report(error: e)
                }
            })
        }
    }
    
    /**
     Clears the given entities from the persistent container
     - parameter container: the container referencing the given entities
     - parameter entities: the entities to clear from the container
     - parameter completion: the callback to perform when the clear is completed
     - Returns: void
     */
    func clearCurrent(_ container:NSPersistentContainer, with entities:[NSFetchRequest<NSFetchRequestResult>], completion:(()->Void)) {
        
        for entity in entities {
            LocalStoreManager.clear(fetched: entity, in:container)
        }
        
        completion()
    }
    
    /**
     Clears an entity type from the given container
     - parameter entity: the NSFetchRequest for the entity to clear
     - parameter container: the container that should be cleared
     - Returns: void
     */
    class func clear(fetched entity:NSFetchRequest<NSFetchRequestResult>, in container:NSPersistentContainer) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: entity)
        
        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
            try container.viewContext.save()
        } catch let e as NSError {
            ErrorHandler.report(error: e)
        }
    }
}

// MARK: - Insert operations

private extension LocalStoreManager {
    
    /**
     Inserts a set of CityParameters into a managed object context
     - parameter cities: a set of CityParameters
     - parameter context: the NSManagedObjectContext to insert into
     - Returns: void
     */
    class func insert(cities:Set<CityParameters>, into context:NSManagedObjectContext) {
        for parameters in cities {
            LocalStoreManager.insert(city:parameters, into: context )
        }
    }
    
    /**
     Inserts a CityParameter object into a managed object context
     - parameter parameters: the CityParameters that should be inserted
     - parameter context: the NSManagedObjectContex to insert into
     - Returns: void
     */
    class func insert(city parameters:CityParameters, into context:NSManagedObjectContext ) {
        let record = NSEntityDescription.insertNewObject(forEntityName:LocalStoreManager.cityEntityKey, into:context) as! City
        record.city = parameters.name
        record.state = parameters.state
        record.population = parameters.population
    }
    
    /**
     Inserts a array of ZipCodeParameters into a managed object context
     - parameter zipCodes: an array of ZipCodeParameters
     - parameter context: the NSManagedObjectContext to insert into
     - Returns: void
     */
    class func insert(zipCodes:[ZipCodeParameters], into context:NSManagedObjectContext) {
        for parameters in zipCodes {
            LocalStoreManager.insert(zipCode: parameters, into: context)
        }
    }
    
    /**
     Inserts a ZipCodeParameters object into a managed object context
     - parameter parameters: the ZipCodeParameters that should be inserted
     - parameter context: the NSManagedObjectContex to insert into
     - Returns: void
     */
    class func insert(zipCode parameters:ZipCodeParameters, into context:NSManagedObjectContext) {
        let record = NSEntityDescription.insertNewObject(forEntityName: LocalStoreManager.zipCodeEntityKey, into: context) as! ZipCode
        record.city = parameters.city
        record.state = parameters.state
        record.latitude = parameters.latitude
        record.longitude = parameters.longitude
        record.population = parameters.population
        record.ident = parameters.ident
    }
}

// MARK: - Notifications

extension LocalStoreManager {
    /**
     Registers for notifications
     - Returns: void
     */
    func registerForNotification() {
        deregisterForNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSaveNotification(sender:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    /**
     Deregisters for notifications
     - Returns: void
     */
    func deregisterForNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    /**
     Performs an action when the save notification is posted
     - parameter sender: the posted notification
     - Returns: void
     */
    @objc func onSaveNotification(sender:Notification) {
        if let context = sender.object as? NSManagedObjectContext {
            if context == persistentContainer.viewContext {
                return
            }
        }
        
        deregisterForNotifications()
        
        let cityCount = try? persistentContainer.viewContext.count(for: allCitiesRequest)
        print("Saved \(cityCount ?? 0) cities")
        let zipCodeCount = try? persistentContainer.viewContext.count(for: allZipCodesRequest)
        print("Saved \(zipCodeCount ?? 0) zip codes\n\n")
        
        DispatchQueue.main.async { [weak self] in
            self?.saveCompletion?()
            self?.saveCompletion = nil
        }
    }
}
