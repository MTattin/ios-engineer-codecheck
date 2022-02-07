//
//  XCTestCase+extension.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import XCTest

extension XCTestCase {
    ///
    ///
    ///
    func isWaitToAppear(for element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == XCTWaiter.Result.completed
    }
    ///
    ///
    ///
    func isWaitToDisAppear(for element: XCUIElement, timeout: TimeInterval = 10.0) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == XCTWaiter.Result.completed
    }
    ///
    ///
    ///
    func waitToDisAppear(for element: XCUIElement, timeout: TimeInterval = 5.0) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed)
    }
    ///
    ///
    ///
    func waitToHittable(for element: XCUIElement, timeout: TimeInterval = 5.0) -> XCUIElement {
        let predicate = NSPredicate(format: "exists == true && hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed)
        return element
    }
    ///
    ///
    ///
    func shootScreen(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = XCTAttachment.Lifetime.keepAlways
        add(attachment)
    }
}
