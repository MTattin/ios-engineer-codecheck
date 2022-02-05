//
//  SearchModel.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/05.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import os

// MARK: -------------------- SearchModelInOut
///
/// - Tag: SearchModelInOut
///
typealias SearchModelInOut = SearchModelInput & SearchModelOutput

// MARK: -------------------- SearchModelInput
///
/// - Tag: SearchModelInput
///
protocol SearchModelInput {
    ///
    func search(by searchWord: String?) -> Task<Void, Never>
}

// MARK: -------------------- SearchModelOutput
///
/// - Tag: SearchModelOutput
///
protocol SearchModelOutput {
    ///
    var didLoad: PassthroughSubject<Result<SearchResponse, APIError>, Never> { get }
    ///
    var didUpdateRateLimit: PassthroughSubject<RateLimit, Never> { get }
}

// MARK: -------------------- SearchModel
///
/// - Tag: SearchModel
///
struct SearchModel: SearchModelOutput {

    // MARK: -------------------- typealias
    ///
    /// - Note: APIClient
    ///
    typealias ResponseData = SearchResponse

    // MARK: -------------------- Variables
    ///
    /// - Note: SearchModelOutput protocol
    ///
    let didLoad = PassthroughSubject<Result<SearchResponse, APIError>, Never>()
    ///
    /// - Note: SearchModelOutput protocol
    ///
    let didUpdateRateLimit = PassthroughSubject<RateLimit, Never>()
}

// MARK: -------------------- SearchModelInput
///
///
///
extension SearchModel: SearchModelInput {
    ///
    ///
    ///
    func search(by searchWord: String?) -> Task<Void, Never> {
        Task {
            do {
                let searchResponse = try await requestSearchAPI(by: searchWord)
                didLoad.send(.success(searchResponse))
            } catch let error as APIError {
                didLoad.send(.failure(error))
                return
            } catch let error {
                if Task.isCancelled {
                    didLoad.send(.failure(.cancelled))
                    return
                }
                OSLog.loggerOfAPP.error("🍎 Unexpected response: \(error.localizedDescription)")
                didLoad.send(.failure(.other(message: error.localizedDescription)))
                return
            }
        }
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func requestSearchAPI(by searchWord: String?) async throws -> ResponseData {
        let url = try repositoriesSearchURL(by: searchWord)
        return try await load(from: url)
    }
    ///
    ///
    ///
    private func repositoriesSearchURL(by searchWord: String?) throws -> URL {
        guard let word = searchWord, !word.isEmpty else {
            throw APIError.emptyKeyWord
        }
        guard
            let queryWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url: URL = URL(
                string: "https://api.github.com/search/repositories?q=\(queryWord)")
        else {
            throw APIError.canNotMakeRequestURL
        }
        return url
    }
}

// MARK: -------------------- APIClient
///
///
///
extension SearchModel: APIClient {
    ///
    ///
    ///
    func validate(data: Data, httpResponse: HTTPURLResponse) throws -> ResponseData {
        try updateRatelimit(of: httpResponse)
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpStatus(code: httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(SearchResponse.self, from: data)
        } catch let error {
            OSLog.loggerOfAPP.error("🍎 Decode exception: \(error.localizedDescription)")
            throw APIError.canNotExtractBody
        }
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func updateRatelimit(of httpResponse: HTTPURLResponse) throws {
        guard
            let remainingValue = httpResponse.allHeaderFields["x-ratelimit-remaining"] as? String,
            let remaining = Int(remainingValue),
            let resetUTCValue = httpResponse.allHeaderFields["x-ratelimit-reset"] as? String,
            let resetUTC = TimeInterval(resetUTCValue)
        else {
            throw APIError.canNotExtractHeader
        }
        didUpdateRateLimit.send(
            RateLimit(remaining: remaining, resetUTC: resetUTC)
        )
    }
}
