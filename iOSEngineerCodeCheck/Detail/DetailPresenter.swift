//
//  DetailPresenter.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/04.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import UIKit

// MARK: -------------------- DetailPresenterInOut
///
/// - Tag: DetailPresenterInOut
///
typealias DetailPresenterInOut = DetailPresenterInput & DetailPresenterOutput

// MARK: -------------------- DetailPresenterInput
///
/// - Tag: DetailPresenterInput
///
protocol DetailPresenterInput {
    ///
    func viewDidLoad()
}

// MARK: -------------------- DetailPresenterOutput
///
/// - Tag: DetailPresenterOutput
///
protocol DetailPresenterOutput {
    ///
    var didLoadRepositorySummary: PassthroughSubject<RepositorySummary, Never> { get }
    ///
    var didLoadAvatar: PassthroughSubject<UIImage, APIError> { get }
}

// MARK: -------------------- DetailPresenter
///
/// - Tag: DetailPresenter
///
final class DetailPresenter: DetailPresenterOutput {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private let repositorySummary: RepositorySummary
    ///
    private let detailAvatarModel: DetailAvatarModelInOut
    ///
    /// - Note: DetailPresenterOutput protocol
    ///
    let didLoadRepositorySummary = PassthroughSubject<RepositorySummary, Never>()
    ///
    /// - Note: DetailPresenterOutput protocol
    ///
    var didLoadAvatar: PassthroughSubject<UIImage, APIError> {
        detailAvatarModel.didLoadAvatar
    }

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init(summary: RepositorySummary, model: DetailAvatarModelInOut) {
        repositorySummary = summary
        detailAvatarModel = model
    }
}

// MARK: -------------------- DetailPresenterInput
///
///
///
extension DetailPresenter: DetailPresenterInput {
    ///
    ///
    ///
    func viewDidLoad() {
        didLoadRepositorySummary.send(repositorySummary)
        detailAvatarModel.load(from: repositorySummary.owner?.avaterURL)
    }
}
