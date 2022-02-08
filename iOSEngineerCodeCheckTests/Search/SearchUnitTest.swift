//
//  SearchUnitTest.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import XCTest

@testable import iOSEngineerCodeCheck

// MARK: -------------------- SearchUnitTest
///
/// - Tag: SearchUnitTest
///
final class SearchUnitTest: XCTestCase {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private let mockModel = MockSearchModel()
    ///
    private lazy var presenter = SearchPresenter(model: mockModel)
    ///
    private var viewController: SearchViewController!

    // MARK: -------------------- Test cycle
    ///
    ///
    ///
    override func setUpWithError() throws {
        mockModel.testCase = self
        if viewController == nil {
            let storyboard = UIStoryboard(name: "Search", bundle: nil)
            viewController = storyboard.instantiateViewController(
                identifier: "SearchViewController",
                creator: { coder in
                    return SearchViewController(
                        coder: coder,
                        presenter: self.presenter
                    )
                }
            )
        }
        viewController.loadView()
        viewController.viewDidLoad()
    }
    ///
    ///
    ///
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: -------------------- Tests
    ///
    ///
    ///
    func test01_ResponseIsEmpty() throws {
        mockModel.mockAPIDataType = .searchCount0
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNil(error)
        XCTAssertTrue(presenter.repositories.isEmpty)
    }
    ///
    ///
    ///
    func test02_ResponseIs7Items() throws {
        mockModel.mockAPIDataType = .searchCount7
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNil(error)
        XCTAssertEqual(presenter.repositories.count, mockAPISearchCount7AssertData.count)
        for i in 0..<mockAPISearchCount7AssertData.endIndex {
            assert(presenter.repositories[i], mockAPISearchCount7AssertData[i])
        }
    }
    ///
    ///
    ///
    func test03_ResponseIsMaxItems() throws {
        mockModel.mockAPIDataType = .searchCount201
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNil(error)
        XCTAssertEqual(presenter.repositories.count, mockAPISearchCount201AssertData.count)
        for i in 0..<mockAPISearchCount201AssertData.endIndex {
            assert(presenter.repositories[i], mockAPISearchCount201AssertData[i])
        }
    }
    ///
    ///
    ///
    func test04_ResponseRateLimited() throws {
        try test02_ResponseIs7Items()
        mockModel.mockAPIDataType = .searchRateLimited
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNotNil(error)
        XCTAssertEqual(
            error,
            APIError.rateLimited(rateLimit: RateLimit(remaining: 0, resetUTC: 3_644_100_000))
        )
        XCTAssertEqual(presenter.repositories.count, mockAPISearchCount7AssertData.count)
        for i in 0..<mockAPISearchCount7AssertData.endIndex {
            assert(presenter.repositories[i], mockAPISearchCount7AssertData[i])
        }
    }
    ///
    ///
    ///
    func test05_ResponseError() throws {
        try test02_ResponseIs7Items()
        mockModel.mockAPIDataType = .searchError
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNotNil(error)
        XCTAssertEqual(error, APIError.httpStatus(code: 500))
        XCTAssertEqual(presenter.repositories.count, mockAPISearchCount7AssertData.count)
        for i in 0..<mockAPISearchCount7AssertData.endIndex {
            assert(presenter.repositories[i], mockAPISearchCount7AssertData[i])
        }
    }
    ///
    ///
    ///
    func test06_ResponseHeaderInvalid() throws {
        try test02_ResponseIs7Items()
        mockModel.mockAPIDataType = .searchHeaderInvalid
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            presenter.search(by: "using mock data")
        }
        let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
        XCTAssertNotNil(error)
        XCTAssertEqual(error, APIError.canNotExtractHeader)
        XCTAssertEqual(presenter.repositories.count, mockAPISearchCount7AssertData.count)
        for i in 0..<mockAPISearchCount7AssertData.endIndex {
            assert(presenter.repositories[i], mockAPISearchCount7AssertData[i])
        }
    }
    ///
    ///
    ///
    func test07_ResponseRequestValid() throws {
        let testStringList: [String] = [
            "A",
            "a AND b AND c AND d AND e AND f",
            "a OR b OR c OR d OR e OR f",
            "a NOT b NOT c NOT d NOT e NOT f",
            "a NOT b OR c AND d NOT e OR f",
            "a NOT b OR c AND d NOT a or a OR f",
            [String](repeating: "あ", count: 256).joined(),
            [String](repeating: "😀", count: 256).joined(),
            [String](repeating: "😀", count: 253).joined() + "👍👍👍",
            [String](repeating: "😀", count: 253).joined() + " AND A AND あ AND 👍",
        ]
        try testStringList.forEach {
            let searchText = $0
            Task {
                try await Task.sleep(nanoseconds: 500_000_000)
                presenter.search(by: searchText)
            }
            let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
            XCTAssertNil(error)
        }
    }
    ///
    ///
    ///
    func test08_ResponseRequestInvalid() throws {
        let testStringList: [String] = [
            "a AND b AND c AND d AND e AND f AND g",
            "a OR b OR c OR d OR e OR f OR g",
            "a NOT b NOT c NOT d NOT e NOT f NOT g",
            "a NOT b AND c OR d NOT e AND f OR g",
            [String](repeating: "あ", count: 257).joined(),
            [String](repeating: "😀", count: 257).joined(),
            [String](repeating: "😀", count: 254).joined() + "👍👍👍",
            [String](repeating: "😀", count: 254).joined() + " AND A AND あ AND 👍",
            [String](repeating: "😀", count: 253).joined() + " AND aa AND あ AND 👍",
        ]
        for i in 0..<testStringList.endIndex {
            let searchText = testStringList[i]
            Task {
                try await Task.sleep(nanoseconds: 500_000_000)
                presenter.search(by: searchText)
            }
            let error = try awaitPublisher(presenter.didLoadRepositories.eraseToAnyPublisher())
            XCTAssertEqual(
                error,
                APIError.invalidRequestQuery(
                    reason: (i < 4) ? .greaterThanLimitOperators : .greaterThanLimitCharacters
                )
            )
        }
    }
    ///
    ///
    ///
    func test09_TapDetailCell() throws {
        try test02_ResponseIs7Items()
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await viewController.tableView(
                viewController.tableView,
                didSelectRowAt: IndexPath(row: 3, section: 0)
            )
        }
        let summary = try awaitPublisher(presenter.didTappedCell.eraseToAnyPublisher())
        assert(summary, mockAPISearchCount7AssertData[3])
        XCTAssertEqual(
            viewController.tableView.visibleCells.endIndex,
            presenter.repositories.endIndex
        )
        let tappedCell = viewController.tableView.cellForRow(at: IndexPath(row: 3, section: 0))
        XCTAssertNotNil(tappedCell)
        XCTAssertEqual((tappedCell as? RepositoryTableViewCell)?.fullName.text, summary.fullName)
        XCTAssertEqual((tappedCell as? RepositoryTableViewCell)?.language.text, summary.language)
        XCTAssertEqual(
            (tappedCell as? RepositoryTableViewCell)?.watchersCcount.text,
            "\(summary.watchersCount ?? 0)"
        )
        XCTAssertEqual(
            (tappedCell as? RepositoryTableViewCell)?.forksCount.text,
            "\(summary.forksCount ?? 0)"
        )
        XCTAssertEqual(
            (tappedCell as? RepositoryTableViewCell)?.stargazersCount.text,
            "\(summary.stargazersCount ?? 0)"
        )
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func assert(_ summary: RepositorySummary, _ assertData: [String: String]) {
        XCTAssertEqual(summary.writtenLanguage, assertData["writtenLanguage"])
        XCTAssertEqual(summary.stargazers, assertData["stargazers"])
        XCTAssertEqual(summary.watchers, assertData["watchers"])
        XCTAssertEqual(summary.forks, assertData["forks"])
        XCTAssertEqual(summary.openIssues, assertData["openIssues"])
        XCTAssertEqual(summary.fullName, assertData["fullName"])
        XCTAssertEqual(summary.owner?.avatarURL, assertData["avatarURL"])
    }
}
