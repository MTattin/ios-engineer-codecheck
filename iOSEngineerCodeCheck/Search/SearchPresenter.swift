//
//  SearchPresenter.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/04.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import Foundation
import UIKit

// MARK: -------------------- SearchPresenterInOut
///
/// - Tag: SearchPresenterInOut
///
typealias SearchPresenterInOut = SearchPresenterInput & SearchPresenterOutput

// MARK: -------------------- SearchPresenterInput
///
/// - Tag: SearchPresenterInput
///
protocol SearchPresenterInput {
    ///
    func cancelSearch()
    ///
    func search(by inputText: String?)
    ///
    func tapCell(at indexPath: IndexPath)
}

// MARK: -------------------- SearchPresenterOutput
///
/// - Tag: SearchPresenterOutput
///
protocol SearchPresenterOutput {
    ///
    var repositories: [RepositorySummary] { get }
    ///
    var didLoadRepositories: PassthroughSubject<APIError?, Never> { get }
    ///
    var didTappedCell: PassthroughSubject<RepositorySummary, Never> { get }
}

// MARK: -------------------- SearchPresenter
///
/// - Tag: SearchPresenter
///
final class SearchPresenter: SearchPresenterOutput {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    ///
    private let searchModel: SearchModelInOut
    ///
    private var searchResponse: SearchResponse?
    ///
    private var rateLimit: RateLimit?
    ///
    private var cancellables = Set<AnyCancellable>()
    ///
    private var searchTask: Task<Void, Never>?
    ///
    /// - Note: SearchPresenterOutput protocol
    ///
    var repositories: [RepositorySummary] {
        searchResponse?.items ?? []
    }
    ///
    /// - Note: SearchPresenterOutput protocol
    ///
    var didLoadRepositories = PassthroughSubject<APIError?, Never>()
    ///
    /// - Note: SearchPresenterOutput protocol
    ///
    let didTappedCell = PassthroughSubject<RepositorySummary, Never>()

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init(model: SearchModelInOut) {
        searchModel = model
        self.sinkSearchModelOutput()
    }
}

// MARK: -------------------- SearchPresenterInput
///
///
///
extension SearchPresenter: SearchPresenterInput {
    ///
    ///
    ///
    func cancelSearch() {
        searchTask?.cancel()
    }
    ///
    ///
    ///
    func search(by inputText: String?) {
        searchTask?.cancel()
        do {
            let url = try searchModel.makeRepositoriesSearchURL(by: inputText)
            searchTask = searchModel.search(by: url)
        } catch let error as APIError {
            didLoadRepositories.send(error)
            return
        } catch let error {
            didLoadRepositories.send(.other(message: error.localizedDescription))
            return
        }
    }
    ///
    ///
    ///
    func tapCell(at indexPath: IndexPath) {
        guard
            let items = searchResponse?.items,
            indexPath.row < items.endIndex
        else {
            return
        }
        didTappedCell.send(items[indexPath.row])
    }
}

// MARK: -------------------- SearchModelOutput
///
///
///
extension SearchPresenter {
    ///
    ///
    ///
    private func sinkSearchModelOutput() {
        searchModel.didUpdateRateLimit
            .sink { [weak self] rateLimit in
                self?.rateLimit = rateLimit
            }
            .store(in: &cancellables)
        searchModel.didLoad
            .sink { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.sendError(using: error)
                    return
                case .success(let searchResponse):
                    self?.searchResponse = searchResponse
                    self?.didLoadRepositories.send(nil)
                    return
                }
            }
            .store(in: &cancellables)
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func sendError(using error: APIError) {
        guard
            error == APIError.httpStatus(code: 403),
            let rateLimit = rateLimit
        else {
            self.didLoadRepositories.send(error)
            return
        }
        self.didLoadRepositories.send(
            (rateLimit.isRateLimited()) ? .rateLimited(rateLimit: rateLimit) : error
        )
    }
}
