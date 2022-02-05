//
//  APIModel.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/05.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

// MARK: -------------------- SearchResponse
///
/// - Tag: SearchResponse
///
struct SearchResponse: Codable {
    var items: [RepositorySummary]
}

// MARK: -------------------- RepositorySummary
///
/// - Tag: RepositorySummary
///
struct RepositorySummary: Codable {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var language: String?
    ///
    var stargazersCount: Int?
    ///
    var watchersCount: Int?
    ///
    var forksCount: Int?
    ///
    var openIssuesCount: Int?
    ///
    var fullName: String?
    ///
    var owner: RepositoryOwner?
    ///
    var writtenLanguage: String { "Written in \(language ?? "")" }
    ///
    var stargazers: String { "\(stargazersCount ?? 0) stars" }
    ///
    var watchers: String { "\(watchersCount ?? 0) watchers" }
    ///
    var forks: String { "\(forksCount ?? 0) forks" }
    ///
    var openIssues: String { "\(openIssuesCount ?? 0) open issues" }

    // MARK: -------------------- CodingKeys
    ///
    ///
    ///
    enum CodingKeys: String, CodingKey {
        ///
        case language
        ///
        case stargazersCount = "stargazers_count"
        ///
        case watchersCount = "watchers_count"
        ///
        case forksCount = "forks_count"
        ///
        case openIssuesCount = "open_issues_count"
        ///
        case fullName = "full_name"
        ///
        case owner
    }
}

// MARK: -------------------- RepositoryOwner
///
/// - Tag: RepositoryOwner
///
struct RepositoryOwner: Codable {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var avaterURL: String?

    // MARK: -------------------- CodingKeys
    ///
    ///
    ///
    enum CodingKeys: String, CodingKey {
        ///
        case avaterURL = "avatar_url"
    }
}

// MARK: -------------------- RateLimit
///
/// APIのレスポンスヘッダーの制限判定
///
/// - Tag: RateLimit
///
struct RateLimit {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var remaining: Int
    ///
    var resetUTC: TimeInterval

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    func isRateLimited() -> Bool {
        if remaining > 0 {
            return false
        }
        return resetUTC > Date().timeIntervalSince1970
    }
}
