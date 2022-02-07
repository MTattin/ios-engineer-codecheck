//
//  DetailUnitTest.swift
//  iOSEngineerCodeCheckTests
//
//  Created by Masakiyo Tachikawa on 2022/02/06.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import XCTest

@testable import iOSEngineerCodeCheck

// MARK: -------------------- DetailUnitTest
///
/// - Tag: DetailUnitTest
///
final class DetailUnitTest: XCTestCase {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private let mockModel = MockDetailAvatarModel()
    ///
    private var presenter: DetailPresenter!
    ///
    private var viewController: DetailViewController!

    // MARK: -------------------- Test cycle
    ///
    ///
    ///
    override func setUpWithError() throws {
        mockModel.testCase = self
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
    func test01_LoadAvatar() throws {
        mockModel.mockAPIDataType = .loadAvatar
        presenter = DetailPresenter(
            summary: mockDetailRepositorySummaryData[0],
            model: mockModel
        )
        makeViewController()
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            await viewController.viewDidLoad()
        }
        var error: APIError?
        var image: UIImage?
        var summary: RepositorySummary
        summary = try awaitPublisher(presenter.didLoadRepositorySummary.eraseToAnyPublisher())
        do {
            image = try awaitPublisher(presenter.didLoadAvatar.eraseToAnyPublisher())
        } catch let e {
            error = e as? APIError
        }
        XCTAssertNil(error)
        XCTAssertNotNil(image)
        let mockImage = makeAvatarImage(by: .loadAvatar)
        XCTAssertEqual(image?.size, mockImage.size)
        XCTAssertEqual(image?.scale, mockImage.scale)
        XCTAssertEqual(image?.pngData()?.count, mockImage.pngData()?.count)
        assert(summary, mockDetailRepositorySummaryAssertData[0])
    }
    ///
    ///
    ///
    func test02_LoadAvatarError() throws {
        mockModel.mockAPIDataType = .loadAvatarError
        presenter = DetailPresenter(
            summary: mockDetailRepositorySummaryData[1],
            model: mockModel
        )
        makeViewController()
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            await viewController.viewDidLoad()
        }
        var error: APIError?
        var image: UIImage?
        var summary: RepositorySummary
        summary = try awaitPublisher(presenter.didLoadRepositorySummary.eraseToAnyPublisher())
        do {
            image = try awaitPublisher(presenter.didLoadAvatar.eraseToAnyPublisher())
        } catch let e {
            error = e as? APIError
        }
        XCTAssertNotNil(error)
        XCTAssertEqual(
            error,
            APIError.httpStatus(code: 500)
        )
        XCTAssertNil(image)
        assert(summary, mockDetailRepositorySummaryAssertData[1])
    }
    ///
    ///
    ///
    func test03_LoadAvatarInvalidImage() throws {
        mockModel.mockAPIDataType = .loadAvatarInvalidImage
        presenter = DetailPresenter(
            summary: mockDetailRepositorySummaryData[2],
            model: mockModel
        )
        makeViewController()
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            await viewController.viewDidLoad()
        }
        var error: APIError?
        var image: UIImage?
        var summary: RepositorySummary
        summary = try awaitPublisher(presenter.didLoadRepositorySummary.eraseToAnyPublisher())
        do {
            image = try awaitPublisher(presenter.didLoadAvatar.eraseToAnyPublisher())
        } catch let e {
            error = e as? APIError
        }
        XCTAssertNotNil(error)
        XCTAssertEqual(
            error,
            APIError.notImageData
        )
        XCTAssertNil(image)
        assert(summary, mockDetailRepositorySummaryAssertData[2])
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func makeViewController() {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        viewController = storyboard.instantiateInitialViewController { coder in
            return DetailViewController(
                coder: coder,
                presenter: self.presenter
            )
        }!
        viewController.loadView()
    }
    ///
    ///
    ///
    private func makeAvatarImage(by mockType: MockAPIDataType) -> UIImage {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: mockType.rawValue, ofType: mockType.extType)!
        return UIImage(contentsOfFile: path)!
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
