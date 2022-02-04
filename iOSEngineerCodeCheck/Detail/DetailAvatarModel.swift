//
//  DetailAvatarModel.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/04.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import UIKit
import os

// MARK: -------------------- DetailAvatarModelInOut
///
/// - Tag: DetailAvatarModelInOut
///
typealias DetailAvatarModelInOut = DetailAvatarModelInput & DetailAvatarModelOutput

// MARK: -------------------- DetailAvatarModelInput
///
/// - Tag: DetailAvatarModelInput
///
protocol DetailAvatarModelInput {
    ///
    func load(from avatarURLString: String?)
}

// MARK: -------------------- DetailAvatarModelOutput
///
/// - Tag: DetailAvatarModelOutput
///
protocol DetailAvatarModelOutput {
    ///
    var didLoadAvatar: PassthroughSubject<UIImage, APIError> { get }
}

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

// MARK: -------------------- DetailAvatarModel
///
/// - Tag: DetailAvatarModel
///
struct DetailAvatarModel: DetailAvatarModelOutput {

    // MARK: -------------------- Variables
    ///
    /// - Note: DetailAvatarModelOutput protocol
    ///
    let didLoadAvatar = PassthroughSubject<UIImage, APIError>()
}

// MARK: -------------------- DetailAvatarModelInput
///
///
///
extension DetailAvatarModel: DetailAvatarModelInput {
    ///
    ///
    ///
    func load(from avatarURLString: String?) {
        guard
            let avatarURLString = avatarURLString,
            let avaterURL = URL(string: avatarURLString)
        else {
            self.didLoadAvatar.send(
                completion: .failure(APIError.other(message: "Invalid avatar URL")))
            return
        }
        Task {
            do {
                let image = try await loadAvatar(from: avaterURL)
                didLoadAvatar.send(image)
            } catch let error as APIError {
                OSLog.loggerOfAPP.debug("🍏 Avatar API error: \(error)")
                didLoadAvatar.send(completion: .failure(error))
                return
            } catch let error {
                OSLog.loggerOfAPP.error("🍎 Unexpected response: \(error.localizedDescription)")
                didLoadAvatar.send(
                    completion: .failure(APIError.other(message: "Unexpected response")))
                return
            }
        }
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func loadAvatar(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return try self.validate(data: data, response: response)
    }
    ///
    ///
    ///
    private func validate(data: Data, response: URLResponse) throws -> UIImage {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other(message: "Not http response")
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.other(message: "Status code is \(httpResponse.statusCode)")
        }
        guard let avatar = UIImage(data: data) else {
            throw APIError.notImageData
        }
        return avatar
    }
}
