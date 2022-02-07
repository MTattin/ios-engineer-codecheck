//
//  MockAPIData.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

// MARK: -------------------- MockAPIDataType
///
/// - Tag: MockAPIDataType
///
enum MockAPIDataType: String {
    ///
    case searchCount0 = "MockAPISearchCount0"
    ///
    case searchCount7 = "MockAPISearchCount7"
    ///
    case searchCount201 = "MockAPISearchCount201"
    ///
    case searchRateLimited = "MockAPISearchRateLimited"
    ///
    case searchError = "MockAPISearchError"
    ///
    case searchHeaderInvalid = "MockAPISearchHeaderInvalid"
    ///
    case loadAvatar = "MockLoadAvatar"
    ///
    case loadAvatarError = "MockLoadAvatarError"
    ///
    case loadAvatarInvalidImage = "MockLoadAvatarInvalidImage"

    // MARK: -------------------- Variables
    
    
    var extType: String {
        if [.loadAvatar, .loadAvatarError].contains(self) {
            return "png"
        }
        return "json"
    }
    ///
    ///
    ///
    var statusCode: Int {
        if self == .searchRateLimited {
            return 403
        }
        if [.searchError, .loadAvatarError].contains(self) {
            return 500
        }
        return 200
    }
    ///
    ///
    ///
    var headerFields: [String: String]? {
        if [.loadAvatar, .loadAvatarError].contains(self) {
            return nil
        }
        if self == .searchRateLimited {
            return [
                "x-ratelimit-remaining": "0",
                "x-ratelimit-reset": "3644100000",
            ]
        }
        if self == .searchHeaderInvalid {
            return [
                "x-ratelimit-remaining-dummy": "10",
                "x-ratelimit-reset-dummy": "3644100000",
            ]
        }
        return [
            "x-ratelimit-remaining": "10",
            "x-ratelimit-reset": "2644100000",
        ]
    }
    ///
    ///
    ///
    var requestURL: URL {
        URL(string: "https://api.github.com/search/repositories?q=")!
    }
}
