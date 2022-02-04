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
    case emptyKeyWord
    ///
    case canNotMakeRequestURL
    /// 制限状態でのAPIをコール
    case rateLimited
    ///
    case canNotExtractHeader
    ///
    case canNotExtractBody
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
        case .emptyKeyWord:
            return "emptyKeyWord"
        case .canNotMakeRequestURL:
            return "canNotMakeRequestURL"
        case .rateLimited:
            return "rateLimited"
        case .canNotExtractHeader:
            return "canNotExtractHeader"
        case .canNotExtractBody:
            return "canNotExtractBody"
        case .other(let message):
            return "other - \(message)"
        }
    }
}
