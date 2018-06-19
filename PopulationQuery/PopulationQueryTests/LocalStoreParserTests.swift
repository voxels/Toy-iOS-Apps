//
//  LocalStoreParserTests.swift
//  PopulationQueryTests
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import XCTest
@testable import PopulationQuery

class LocalStoreParserTests: XCTestCase {
    
    var testData:[[String:Any]]?
    
    /*
     { "_id" : "01001", "city" : "AGAWAM", "loc" : [ -72.622739, 42.070206 ], "pop" : 15338, "state" : "MA" }
     { "_id" : "01002", "city" : "CUSHMAN", "loc" : [ -72.51564999999999, 42.377017 ], "pop" : 36963, "state" : "MA" }
     { "_id" : "03592", "city" : "PITTSBURG", "loc" : [ -71.36359299999999, 45.086564 ], "pop" : 1104, "state" : "NH" }
     */
    
    override func setUp() {
        super.setUp()
        let row0:[String:Any] = ["_id":"01000", "city":"AGAWAM", "loc":[-72.622739, 42.070206], "pop" : Double(100), "state":"MA"]
        let row1:[String:Any] = ["_id":"01001", "city":"AGAWAM", "loc":[-72.622739, 42.070206], "pop" : Double(15338), "state":"MA"]
        let row2:[String:Any] = ["_id":"01002", "city":"CUSHMAN", "loc":[-72.51564999999999, 42.377017], "pop" : Double(36963), "state":"MA"]
        let row3:[String:Any] = ["_id":"03592", "city":"PITTSBURG", "loc":[-71.36359299999999, 45.086564], "pop" : Double(1104), "state":"NH"]

        testData = [row0, row1, row2, row3]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateParametersCreatesCityParametersSet() {
        guard let data = testData else {
            XCTFail()
            return
        }
        
        let expect = self.expectation(description: "Wait for expectation")
        
        LocalStoreParser.createParameters(with: data, completion: { (cities, zipCodes) in
            XCTAssertTrue(cities.count == 3, "Did not find the correct number of cities in the set")
            let check = cities.filter({ (parameters) -> Bool in
                return parameters.name == "AGAWAM"
            }).first
            
            XCTAssertTrue(check?.population == Double(15438), "City population was not aggregated")
            
            expect.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1) { (error) in
            if let e = error {
                print("error: \(e)")
            }
        }
    }
    
    func testCreateParametersCreatesZipParameters() {
        guard let data = testData else {
            XCTFail()
            return
        }
        
        let expect = self.expectation(description: "Wait for expectation")
        
        LocalStoreParser.createParameters(with: data, completion: { (cities, zipCodes) in
            XCTAssertTrue(zipCodes.count == 4, "Did not find the correct number of zip codes in the array")
            
            let check = zipCodes.filter({ (parameters) -> Bool in
                return parameters.city == "AGAWAM"
            })
            
            XCTAssertTrue(check.count == 2, "Did not find the correct number of entries in parameters")

            expect.fulfill()
        })
        
        self.waitForExpectations(timeout: 0.1) { (error) in
            if let e = error {
                print("error: \(e)")
            }
        }
    }
    
    func testStateParametersCreatesParametersFromDict() {
        let stateName = "MA"
        let population = Double(100)
        let stateData:[String:Any] = [CityKey.state.rawValue : stateName, CityKey.population.rawValue : population]
        let parameters = LocalStoreParser.stateParameters(from: stateData)
        
        XCTAssertTrue(parameters?.abbreviation == stateName, "Did not find correct state name in parameters")
        XCTAssertTrue(parameters?.population == population, "Did not find correct state name in parameters")
    }
}
