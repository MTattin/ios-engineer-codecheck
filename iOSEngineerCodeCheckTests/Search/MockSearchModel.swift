//
//  MockSearchModel.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation
import Combine
import XCTest

@testable import iOSEngineerCodeCheck

// MARK: -------------------- MockSearchModel
///
/// - Tag: MockSearchModel
///
final class MockSearchModel: SearchModelOutput {

    // MARK: -------------------- typealias
    ///
    /// - Note: APIClient
    ///
    typealias ResponseData = SearchResponse

    // MARK: -------------------- Variables
    ///
    /// - Note: SearchModelOutput protocol
    ///
    var didLoad: PassthroughSubject<Result<SearchResponse, APIError>, Never>
    ///
    /// - Note: SearchModelOutput protocol
    ///
    var didUpdateRateLimit: PassthroughSubject<RateLimit, Never>
    ///
    ///
    ///
    weak var testCase: XCTestCase!
    ///
    ///
    ///
    var mockAPIDataType = MockAPIDataType.searchCount0
    ///
    ///
    ///
    let searchModel: SearchModel = SearchModel()
    
    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init() {
        didLoad = searchModel.didLoad
        didUpdateRateLimit = searchModel.didUpdateRateLimit
    }
}

// MARK: -------------------- SearchModelInput
///
///
///
extension MockSearchModel: SearchModelInput {
    ///
    ///
    ///
    func search(by url: URL) -> Task<Void, Never> {
        Task {
            do {
                let searchResponse = try await load(from: url)
                didLoad.send(.success(searchResponse))
            } catch let error as APIError {
                didLoad.send(.failure(error))
                return
            } catch let error {
                if Task.isCancelled {
                    didLoad.send(.failure(.cancelled))
                    return
                }
                didLoad.send(.failure(.other(message: error.localizedDescription)))
                return
            }
        }
    }
    ///
    ///
    ///
    func makeRepositoriesSearchURL(by searchText: String?) throws -> URL {
        return try searchModel.makeRepositoriesSearchURL(by: searchText)
    }
}

// MARK: -------------------- APIClient
///
///
///
extension MockSearchModel: APIClient {
    ///
    ///
    ///
    func load(from url: URL) async throws -> ResponseData {
        let (data, httpResponse) = testCase.makeMockAPIData(of: mockAPIDataType)
        return try validate(data: data, httpResponse: httpResponse)
    }
    ///
    ///
    ///
    func validate(data: Data, httpResponse: HTTPURLResponse) throws -> ResponseData {
        return try searchModel.validate(data: data, httpResponse: httpResponse)
    }
}
