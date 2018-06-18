//
//  SettingsTests.swift
//  TimeTurnerTests
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

import XCTest
@testable import TimeTurner

class MockUserDefaults : UserDefaults {
    
    static let kSuiteName = "com.secretatomics.UserDefaults.Testing"
    convenience init() {
        self.init(suiteName: MockUserDefaults.kSuiteName)!
    }
    
    override init?(suiteName suitename: String?) {
        guard let suiteName = suitename else {
            return nil
        }
        UserDefaults().removePersistentDomain(forName: suiteName)
        super.init(suiteName: suiteName)
    }
}

class SettingsTests: XCTestCase {
    
    let mockUserDefaults = MockUserDefaults()
    
    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: MockUserDefaults.kSuiteName)
        super.tearDown()
    }

    
    func testShouldShowTime() {
        let showTime = Settings.shouldShowTime(with: mockUserDefaults)
        XCTAssertFalse(showTime)
    }

    func testUpdateShowTime() {
        var showTime = Settings.shouldShowTime(with: mockUserDefaults)
        XCTAssertFalse(showTime)
    
        Settings.updateShowTime(shouldStore: true, with: mockUserDefaults)
        showTime = Settings.shouldShowTime(with: mockUserDefaults)
        XCTAssertTrue(showTime)
    }
    
    func testStoredLocale() {
        let emptyLocale = Settings.storedLocaleIdentifier(with: mockUserDefaults)
        XCTAssertNil(emptyLocale)
        
        let currentLocale = Settings.storedLocale(with:mockUserDefaults)
        XCTAssertEqual(currentLocale, Locale.autoupdatingCurrent)
    }
    
    func testUpdateStoredLocaleWithIdentifer() {
        let identifier = "fr_FR"
        let expected = Locale(identifier: identifier)
        Settings.updateStored(locale: expected, with: mockUserDefaults)
        let actual = Settings.storedLocale(with: mockUserDefaults)
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateStoredLocaleWithNil() {
        let identifier = "fr_FR"
        let locale = Locale(identifier: identifier)
        Settings.updateStored(locale: locale, with: mockUserDefaults)
        let checkLocale = Settings.storedLocale(with: mockUserDefaults)
        XCTAssertEqual(locale, checkLocale)
        Settings.updateStored(locale: nil, with: mockUserDefaults)
        let actual = mockUserDefaults.object(forKey: Settings.key(item: .locale))
        XCTAssertNil(actual)
    }
}
