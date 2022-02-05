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
    func load(from avatarURLString: String?) {
        guard
            let avatarURLString = avatarURLString,
            let avaterURL = URL(string: avatarURLString)
        else {
            didLoadAvatar.send(completion: .failure(APIError.other(message: "Invalid avatar URL")))
            return
        }
        Task {
            do {
                let avatar = try await load(from: avaterURL)
                didLoadAvatar.send(avatar)
            } catch let error as APIError {
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
