//
//  MockDetailAvatarData.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

@testable import iOSEngineerCodeCheck

// MARK: -------------------- mockDetailRepositorySummaryData
///
///
///
let mockDetailRepositorySummaryData: [RepositorySummary] = [
    RepositorySummary(
        language: "TestLanguage",
        stargazersCount: 1,
        watchersCount: 1,
        forksCount: 1,
        openIssuesCount: 1,
        fullName: "TestFullName",
        owner: RepositoryOwner(
            avatarURL: "https://avatars.githubusercontent.com/u/6687975?v=4"
        )
    ),
    RepositorySummary(
        language: "Test02Language",
        stargazersCount: 11111,
        watchersCount: 22222,
        forksCount: 33333,
        openIssuesCount: 44444,
        fullName: "Test02FullName",
        owner: RepositoryOwner(
            avatarURL: "https://avatars.githubusercontent.com/u/6687975?v=test02"
        )
    ),
    RepositorySummary(
        language: "Test03Language",
        stargazersCount: 0,
        watchersCount: 0,
        forksCount: 0,
        openIssuesCount: 0,
        fullName: "Test03FullName",
        owner: RepositoryOwner(
            avatarURL: "https://avatars.githubusercontent.com/u/6687975?v=test03"
        )
    ),
]

// MARK: -------------------- mockDetailRepositorySummaryAssertData
///
///
///
let mockDetailRepositorySummaryAssertData: [[String: String]] = [
    [
        "writtenLanguage": "Written in TestLanguage",
        "stargazers": "1 star",
        "watchers": "1 watcher",
        "forks": "1 fork",
        "openIssues": "1 open issue",
        "fullName": "TestFullName",
        "avatarURL": "https://avatars.githubusercontent.com/u/6687975?v=4",
    ],
    [
        "writtenLanguage": "Written in Test02Language",
        "stargazers": "11111 stars",
        "watchers": "22222 watchers",
        "forks": "33333 forks",
        "openIssues": "44444 open issues",
        "fullName": "Test02FullName",
        "avatarURL": "https://avatars.githubusercontent.com/u/6687975?v=test02",
    ],
    [
        "writtenLanguage": "Written in Test03Language",
        "stargazers": "0 stars",
        "watchers": "0 watchers",
        "forks": "0 forks",
        "openIssues": "0 open issues",
        "fullName": "Test03FullName",
        "avatarURL": "https://avatars.githubusercontent.com/u/6687975?v=test03",
    ],
]
