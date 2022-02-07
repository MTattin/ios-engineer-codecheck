//
//  MockDetailAvatarModel.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import XCTest

@testable import iOSEngineerCodeCheck

// MARK: -------------------- MockDetailAvatarModel
///
/// - Tag: MockDetailAvatarModel
///
final class MockDetailAvatarModel: DetailAvatarModelOutput {

    // MARK: -------------------- typealias
    ///
    /// - Note: APIClient
    ///
    typealias ResponseData = UIImage

    // MARK: -------------------- Variables
    ///
    /// - Note: DetailAvatarModelOutput protocol
    ///
    var didLoadAvatar = PassthroughSubject<ResponseData, APIError>()
    ///
    ///
    ///
    weak var testCase: XCTestCase!
    ///
    ///
    ///
    var mockAPIDataType = MockAPIDataType.loadAvatar
    ///
    ///
    ///
    let detailAvatarModel: DetailAvatarModel = DetailAvatarModel()

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init() {
        didLoadAvatar = detailAvatarModel.didLoadAvatar
    }
}

// MARK: -------------------- DetailAvatarModelInput
///
///
///
extension MockDetailAvatarModel: DetailAvatarModelInput {
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
                return
            } catch let error {
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
        return try detailAvatarModel.makeAvatarURL(by: avatarURLString)
    }
}

// MARK: -------------------- APIClient
///
///
///
extension MockDetailAvatarModel: APIClient {
    ///
    ///
    ///
    func load(from url: URL) async throws -> UIImage {
        let (data, httpResponse) = testCase.makeMockAPIData(of: mockAPIDataType)
        return try validate(data: data, httpResponse: httpResponse)
    }
    ///
    ///
    ///
    func validate(data: Data, httpResponse: HTTPURLResponse) throws -> ResponseData {
        return try detailAvatarModel.validate(data: data, httpResponse: httpResponse)
    }
}
