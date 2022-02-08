//
//  iOSEngineerCodeCheckUITests.swift
//  iOSEngineerCodeCheckUITests
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest

// MARK: -------------------- iOSEngineerCodeCheckUITests
///
/// - Tag: iOSEngineerCodeCheckUITests
///
class iOSEngineerCodeCheckUITests: XCTestCase {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private let app = XCUIApplication()
    ///
    var searchListTable: XCUIElement {
        app.tables.element(matching: .table, identifier: "tableView.SearchViewController")
    }
    ///
    var searchTextField: XCUIElement {
        app.searchFields.element(
            matching: .searchField, identifier: "searchBar.searchTextField.SearchViewController")
    }
    ///
    var searchButtonOnKeyboard: XCUIElement {
        app.keyboards.firstMatch.buttons.element(matching: .button, identifier: "Search")
    }
    ///
    var searchClearTextButton: XCUIElement {
        app.searchFields.buttons.firstMatch
    }
    ///
    var toastEmptySearchText: XCUIElement {
        app.staticTexts.element(matching: NSPredicate(format: "label = '検索文字を入力してください'"))
    }
    ///
    var toastRateLimited: XCUIElement {
        app.staticTexts.element(matching: NSPredicate(format: "label = 'APIアクセス制限中'"))
    }
    ///
    var toastInvalidRateLimited: XCUIElement {
        app.staticTexts.element(matching: NSPredicate(format: "label = 'APIアクセス制限中'"))
    }
    ///
    var toastGreaterThanLimitCharacters: XCUIElement {
        app.staticTexts.element(
            matching: NSPredicate(format: "label = '文字数は256文字（演算子や修飾子は除く）以下にしてください。'"))
    }
    ///
    var toastGreaterThanLimitOperators: XCUIElement {
        app.staticTexts.element(
            matching: NSPredicate(format: "label = 'AND、OR、NOTの演算子は、5つ以下にしてください。'"))
    }
    ///
    var detailAvatar: XCUIElement {
        app.images.element(matching: .image, identifier: "avatar.DetailViewController")
    }
    ///
    var detailFullName: XCUIElement {
        app.staticTexts.element(matching: .staticText, identifier: "fullName.DetailViewController")
    }
    ///
    var detailWrittenLanguage: XCUIElement {
        app.staticTexts.element(
            matching: .staticText, identifier: "writtenLanguage.DetailViewController")
    }
    ///
    var detailStargazersCount: XCUIElement {
        app.staticTexts.element(
            matching: .staticText, identifier: "stargazersCount.DetailViewController")
    }
    ///
    var detailWatchersCcount: XCUIElement {
        app.staticTexts.element(
            matching: .staticText, identifier: "watchersCcount.DetailViewController")
    }
    ///
    var detailForksCount: XCUIElement {
        app.staticTexts.element(
            matching: .staticText, identifier: "forksCount.DetailViewController")
    }
    ///
    var detailOpenIssuesCount: XCUIElement {
        app.staticTexts.element(
            matching: .staticText, identifier: "openIssuesCount.DetailViewController")
    }
    ///
    var detailSafariLink: XCUIElement {
        app.buttons.element(
            matching: .button, identifier: "safariLink.DetailViewController")
    }
    ///
    let safariApp: XCUIApplication = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

    // MARK: -------------------- Test cycle
    ///
    ///
    ///
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
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
    func test01_SearchTextEmpty() throws {
        launchAssert()
        searchTextField.tap()
        searchButtonOnKeyboard.tap()
        XCTAssertTrue(isWaitToAppear(for: toastEmptySearchText))
        shootScreen(name: "検索文字未入力トースト")
        waitToDisAppear(for: toastEmptySearchText)
    }
    ///
    ///
    ///
    func test02_SearchTextInvalid() throws {
        launchAssert()
        searchTextField.tap()
        searchTextField.typeText("A AND B AND A AND B AND A AND B AND")
        searchButtonOnKeyboard.tap()
        XCTAssertTrue(isWaitToAppear(for: toastGreaterThanLimitOperators))
        shootScreen(name: "オペレーターオーバー")
        waitToDisAppear(for: toastGreaterThanLimitOperators)
        XCTAssertEqual(searchTextField.value as? String, "A AND B AND A AND B AND A AND B AND")
        searchClearTextButton.tap()
        ///
        searchTextField.tap()
        searchTextField.typeText([String](repeating: "あ", count: 257).joined())
        searchButtonOnKeyboard.tap()
        XCTAssertTrue(isWaitToAppear(for: toastGreaterThanLimitCharacters))
        shootScreen(name: "文字数オーバー")
        waitToDisAppear(for: toastGreaterThanLimitCharacters)
        XCTAssertEqual(
            searchTextField.value as? String, [String](repeating: "あ", count: 257).joined())
        searchClearTextButton.tap()
    }
    ///
    ///
    ///
    func test03_SearchAndShowDetail() throws {
        launchAssert()
        searchTextField.tap()
        searchTextField.typeText("Yumemi")
        searchButtonOnKeyboard.tap()
        if isWaitToAppear(for: toastRateLimited) {
            while isWaitToDisAppear(for: toastRateLimited) {
                sleep(10)
            }
        }
        XCTAssertTrue(app.cells.count > 0)
        waitToHittable(for: app.cells.element(boundBy: 0)).tap()
        XCTAssertTrue(isWaitToAppear(for: detailAvatar))
        XCTAssertTrue(isWaitToAppear(for: detailFullName))
        XCTAssertTrue(isWaitToAppear(for: detailWrittenLanguage))
        XCTAssertTrue(isWaitToAppear(for: detailStargazersCount))
        XCTAssertTrue(isWaitToAppear(for: detailWatchersCcount))
        XCTAssertTrue(isWaitToAppear(for: detailForksCount))
        XCTAssertTrue(isWaitToAppear(for: detailOpenIssuesCount))
        XCTAssertNotNil(waitToHittable(for: detailSafariLink))
        shootScreen(name: "詳細画面")
        waitToHittable(for: app.navigationBars.firstMatch.buttons.firstMatch).tap()
        waitToDisAppear(for: detailAvatar)
        XCTAssertTrue(app.cells.count > 0)
        XCTAssertEqual(searchTextField.value as? String, "Yumemi")
    }
    ///
    ///
    ///
    func test04_SearchAndShowDetailAndOpenSafari() throws {
        launchAssert()
        searchTextField.tap()
        searchTextField.typeText("Yumemi")
        searchButtonOnKeyboard.tap()
        if isWaitToAppear(for: toastRateLimited) {
            while isWaitToDisAppear(for: toastRateLimited) {
                sleep(10)
            }
        }
        XCTAssertTrue(app.cells.count > 0)
        waitToHittable(for: app.cells.element(boundBy: 0)).tap()
        XCTAssertTrue(isWaitToAppear(for: detailAvatar))
        XCTAssertTrue(isWaitToAppear(for: detailFullName))
        XCTAssertTrue(isWaitToAppear(for: detailWrittenLanguage))
        XCTAssertTrue(isWaitToAppear(for: detailStargazersCount))
        XCTAssertTrue(isWaitToAppear(for: detailWatchersCcount))
        XCTAssertTrue(isWaitToAppear(for: detailForksCount))
        XCTAssertTrue(isWaitToAppear(for: detailOpenIssuesCount))
        XCTAssertNotNil(waitToHittable(for: detailSafariLink))
        waitToHittable(for: detailSafariLink).tap()
        XCTAssertTrue(isWaitToAppear(for: safariApp.windows.firstMatch))
        sleep(2)
        shootScreen(name: "Safariで表示")
    }
    ///
    ///
    ///
    func test05_RateLimit() throws {
        launchAssert()
        searchTextField.tap()
        searchTextField.typeText("Yumemi")
        searchButtonOnKeyboard.tap()
        if isWaitToAppear(for: toastRateLimited) {
            shootScreen(name: "レート制限")
            waitToDisAppear(for: toastRateLimited)
            return
        }

        XCTAssertTrue(app.cells.count > 0)
        var assertText = ""
        for i in 0...30 {
            searchTextField.tap()
            if searchTextField.value as? String ?? "Yumemi" == "Yumemi" {
                searchTextField.typeText("Yumemi1")
                assertText = "Yumemi1"
            } else {
                searchTextField.typeText("Yumemi")
                assertText = "Yumemi"
            }
            searchButtonOnKeyboard.tap()
            if isWaitToAppear(for: toastRateLimited, timeout: 2.0) {
                break
            }
            if i == 30 {
                XCTFail("レート制限が30回以上なのでテスト終了")
            }
        }
        shootScreen(name: "レート制限")
        waitToDisAppear(for: toastRateLimited)
        XCTAssertTrue(app.cells.count > 0)
        XCTAssertEqual(searchTextField.value as? String, assertText)
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func launchAssert() {
        app.launch()
        XCTAssertTrue(isWaitToAppear(for: searchListTable, timeout: 5.0))
        XCTAssertTrue(isWaitToAppear(for: searchTextField, timeout: 5.0))
        XCTAssertEqual(searchTextField.placeholderValue, "GitHubのリポジトリを検索できるよー")
        XCTAssertEqual(searchTextField.value as? String, searchTextField.placeholderValue)
    }
}
