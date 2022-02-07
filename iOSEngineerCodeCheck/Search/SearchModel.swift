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
    func makeRepositoriesSearchURL(by searchText: String?) throws -> URL
    ///
    func search(by url: URL) -> Task<Void, Never>
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
    func search(by url: URL) -> Task<Void, Never> {
        Task {
            do {
                let searchResponse = try await load(from: url)
                didLoad.send(.success(searchResponse))
            } catch let error as APIError {
                didLoad.send(.failure(error))
                OSLog.loggerOfAPP.error("🍎 APIError: \(error)")
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
    ///
    ///
    ///
    func makeRepositoriesSearchURL(by searchText: String?) throws -> URL {
        guard let text = searchText, !text.isEmpty else {
            throw APIError.emptySearchText
        }
        let words = text.components(separatedBy: " ")
        if words.filter({ ["AND", "OR", "NOT"].contains($0) }).endIndex > 5 {
            throw APIError.invalidRequestQuery(reason: .greaterThanLimitOperators)
        }
        let queryText = words.filter { !["AND", "OR", "NOT"].contains($0) }.joined()
        if queryText.count > 256 {
            throw APIError.invalidRequestQuery(reason: .greaterThanLimitCharacters)
        }
        guard
            let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url: URL = URL(string: "https://api.github.com/search/repositories?q=\(query)")
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
