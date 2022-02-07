//
//  XCTestCase+extension.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import XCTest

extension XCTestCase {

    // MARK: -------------------- Variables
    ///
    /// Make HTTP response using each mock json file
    ///
    /// About "HTTPURLResponse" of Returns, the "statusCode" and "headerFields" are set based on [MockAPIDataType](x-source-tag://MockAPIDataType).
    ///
    /// - Tag: makeMockAPIData
    ///
    func makeMockAPIData(of mockType: MockAPIDataType) -> (Data, HTTPURLResponse) {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: mockType.rawValue, ofType: mockType.extType)!
        let httpRepsonse = HTTPURLResponse(
            url: mockType.requestURL,
            statusCode: mockType.statusCode,
            httpVersion: nil,
            headerFields: mockType.headerFields
        )!
        return (try! Data(contentsOf: URL(fileURLWithPath: path)), httpRepsonse)
    }
    ///
    ///
    ///
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
                expectation.fulfill()
            }
        )
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        return try unwrappedResult.get()
    }
}
