//
//  ModelControllerTests.swift
//  TimeTurnerTests
//
//  Copyright © 2018 Michael Edgcumbe. All rights reserved.
//

import XCTest
@testable import TimeTurner

class ModelControllerTests: XCTestCase {
    
    let model = ModelController()
    let mockUserDefaults = MockUserDefaults()

    static let kIdentifier = "fr_FR"
    let locale = Locale(identifier: ModelControllerTests.kIdentifier)

    let dayInSeconds:TimeInterval = 86401

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: MockUserDefaults.kSuiteName)
        super.tearDown()
    }
    
    func testUpdateChangesPickerDate() {
        let originalPickerDate = model.pickerDate
        let expected = Date(timeInterval: dayInSeconds, since: originalPickerDate)
        model.update(date: expected)
        let actual = model.pickerDate
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesSelectedDay() {
        let originalPickerDate = model.pickerDate
        model.update(date: originalPickerDate)
        let checkDate = Date.init(timeIntervalSinceReferenceDate: 0)
        model.update(date: checkDate)
        let expected = 0
        let actual = model.selectedDay
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesLastSelectedDay() {
        let lastDate = Date.init(timeIntervalSinceReferenceDate: -1 * dayInSeconds)
        model.update(date: lastDate)
        let updateDate = Date.init(timeIntervalSinceReferenceDate: 0)
        model.update(date: updateDate)
        let expected = 6
        let actual = model.lastSelectedDay
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesPickerTitle() {
        let checkDate = Date.init(timeIntervalSinceReferenceDate: 0)
        model.didChooseDate = true
        model.update(date: checkDate)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Settings.storedLocale(with: mockUserDefaults)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = Settings.shouldShowTime(with:mockUserDefaults) ? .medium : .none
        let expected = dateFormatter.string(from: model.pickerDate)
        let actual = model.pickerTitle
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesIsoTitle() {
        let checkDate = Date.init(timeIntervalSinceReferenceDate: 0)
        model.update(date: checkDate)
        let expected = model.pickerDate.iso8601(for: Settings.storedLocale(with: mockUserDefaults))
        let actual = model.isoTitle
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesCountTitle() {
        let tomorrow = Date.init(timeIntervalSinceNow: 2 * dayInSeconds)
        model.update(date: tomorrow)
        let expected = "2"
        let actual = model.countTitle
        XCTAssertEqual(expected, actual)
    }
    
    func testUpdateChangesCurrentDateTitle() {
        let tomorrow = Date.init(timeIntervalSinceNow: 2 * dayInSeconds)
        model.update(date: tomorrow)

        let dateFormatter = DateIntervalFormatter()
        dateFormatter.locale = Settings.storedLocale(with: mockUserDefaults)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        let expected = dateFormatter.string(from: Date(), to: model.pickerDate)
        let actual = model.countDateTitle
        XCTAssertEqual(expected, actual)
    }
    
    func testSharingText() {
        let expectedTitle = "expectedTitle"
        let expectedDateTitle = "expectedDateTitle"
        let expectedCountTitle = "expectedCountTitle"
        let expected = "ISO 8601:\t\(expectedTitle)\nDays from \(expectedDateTitle):\t\(expectedCountTitle)"
        let actual = model.sharingText(isoTitle: expectedTitle, countDateTitle: expectedDateTitle, countTitle: expectedCountTitle)
        XCTAssertEqual(expected, actual)
    }
}
