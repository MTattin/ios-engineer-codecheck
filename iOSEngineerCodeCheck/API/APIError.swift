//
//  APIError.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/04.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

// MARK: -------------------- APIError
///
/// APIのエラー
///
/// - Tag: APIError
///
enum APIError: Error {
    ///
    case cancelled
    ///
    case emptySearchText
    /// InvalidRequestQueryReason is [here](x-source-tag://InvalidRequestQueryReason)
    case invalidRequestQuery(reason: InvalidRequestQueryReason)
    ///
    case canNotMakeRequestURL
    /// 制限状態でのAPIをコール
    case rateLimited(rateLimit: RateLimit)
    ///
    case canNotExtractHeader
    ///
    case canNotExtractBody
    ///
    case notImageData
    ///
    case httpStatus(code: Int)
    ///
    case other(message: String)
}

// MARK: -------------------- CustomStringConvertible
///
/// Logger様に適用
///
extension APIError: CustomStringConvertible {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var description: String {
        switch self {
        case .cancelled:
            return "cancelled"
        case .emptySearchText:
            return "emptySearchText"
        case .invalidRequestQuery(let reason):
            return "invalidRequestQuery - \(reason.rawValue)"
        case .canNotMakeRequestURL:
            return "canNotMakeRequestURL"
        case .rateLimited(let rateLimit):
            return "rateLimited - \(rateLimit.remaining) - \(rateLimit.resetUTC)"
        case .canNotExtractHeader:
            return "canNotExtractHeader"
        case .canNotExtractBody:
            return "canNotExtractBody"
        case .notImageData:
            return "notImageData"
        case .httpStatus(let code):
            return "httpStatus - \(code)"
        case .other(let message):
            return "other - \(message)"
        }
    }
}

// MARK: -------------------- Equatable
///
///
///
extension APIError: Equatable {
    ///
    ///
    ///
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        lhs.description == rhs.description
    }
}

// MARK: -------------------- InvalidRequestQueryReason
///
/// - Tag: InvalidRequestQueryReason
///
enum InvalidRequestQueryReason: Int {
    ///
    case greaterThanLimitCharacters
    ///
    case greaterThanLimitOperators

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var toastMessage: String {
        switch self {
        case .greaterThanLimitCharacters:
            return NSLocalizedString("search.invalid.query.limit.characters", comment: "")
        case .greaterThanLimitOperators:
            return NSLocalizedString("search.invalid.query.limit.operators", comment: "")
        }
    }
}
