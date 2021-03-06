//
//  APIClient.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/05.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Foundation

// MARK: -------------------- APIClient
///
///
///
protocol APIClient {
    ///
    associatedtype ResponseData
    ///
    func load(from url: URL) async throws -> ResponseData
    ///
    func validate(data: Data, httpResponse: HTTPURLResponse) throws -> ResponseData
}

// MARK: -------------------- Protocol
///
///
///
extension APIClient {
    ///
    ///
    ///
    func load(from url: URL) async throws -> ResponseData {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other(message: "Not http response")
        }
        return try validate(data: data, httpResponse: httpResponse)
    }
}
