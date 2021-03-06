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
    func makeAvatarURL(by avatarURLString: String?) throws -> URL
    ///
    func load(from avatarURL: URL)
}

// MARK: -------------------- DetailAvatarModelOutput
///
/// - Tag: DetailAvatarModelOutput
///
protocol DetailAvatarModelOutput {
    ///
    var didLoadAvatar: PassthroughSubject<UIImage, APIError> { get }
}

// MARK: -------------------- DetailAvatarModel
///
/// - Tag: DetailAvatarModel
///
struct DetailAvatarModel: DetailAvatarModelOutput {

    // MARK: -------------------- typealias
    ///
    /// - Note: APIClient
    ///
    typealias ResponseData = UIImage

    // MARK: -------------------- Variables
    ///
    /// - Note: DetailAvatarModelOutput protocol
    ///
    let didLoadAvatar = PassthroughSubject<ResponseData, APIError>()
}

// MARK: -------------------- DetailAvatarModelInput
///
///
///
extension DetailAvatarModel: DetailAvatarModelInput {
    ///
    ///
    ///
    func load(from avatarURL: URL) {
        Task {
            do {
                let avatar = try await load(from: avatarURL)
                didLoadAvatar.send(avatar)
            } catch let error as APIError {
                didLoadAvatar.send(completion: .failure(error))
                OSLog.loggerOfAPP.error("🍎 APIError: \(error)")
                return
            } catch let error {
                OSLog.loggerOfAPP.error("🍎 Unexpected response: \(error.localizedDescription)")
                didLoadAvatar.send(
                    completion: .failure(APIError.other(message: error.localizedDescription)))
                return
            }
        }
    }
    ///
    ///
    ///
    func makeAvatarURL(by avatarURLString: String?) throws -> URL {
        guard
            let avatarURLString = avatarURLString,
            let url = URL(string: avatarURLString)
        else {
            throw APIError.other(message: "Invalid avatar URL")
        }
        return url
    }
}

// MARK: -------------------- APIClient
///
///
///
extension DetailAvatarModel: APIClient {
    ///
    ///
    ///
    func validate(data: Data, httpResponse: HTTPURLResponse) throws -> ResponseData {
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpStatus(code: httpResponse.statusCode)
        }
        guard let avatar = UIImage(data: data) else {
            throw APIError.notImageData
        }
        return avatar
    }
}
