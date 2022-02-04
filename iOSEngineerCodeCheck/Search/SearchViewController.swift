//
//  SearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import os

// MARK: -------------------- SearchViewController
///
/// GitHubのリポジトリ検索画面
///
/// - Tag: SearchViewController
///
final class SearchViewController: UITableViewController {

    // MARK: -------------------- IBOutlet
    ///
    ///
    ///
    @IBOutlet weak private var searchBar: UISearchBar!

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private var getRepositoriesTask: Task<Void, Never>?
    ///
    private(set) var repositories: [RepositorySummary] = []

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }

    // MARK: -------------------- Transition
    ///
    ///
    ///
    private func pushDetailViewController(of indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let summary = repositories[indexPath.row]
        let detailViewController = storyboard.instantiateInitialViewController { coder in
            return DetailViewController(
                coder: coder,
                presenter: DetailPresenter(
                    summary: summary,
                    model: DetailAvatarModel()
                )
            )
        }!
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

// MARK: -------------------- UITableViewDataSource
///
///
///
extension SearchViewController {
    ///
    ///
    ///
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    ///
    ///
    ///
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        }
        cell.textLabel?.text = repositories[indexPath.row].fullName ?? ""
        cell.detailTextLabel?.text = repositories[indexPath.row].language ?? ""
        return cell
    }
}

// MARK: -------------------- UITableViewDelegate
///
///
///
extension SearchViewController {
    ///
    ///
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pushDetailViewController(of: indexPath)
    }
}

// MARK: -------------------- UISearchBarDelegate
///
///
///
extension SearchViewController: UISearchBarDelegate {
    ///
    ///
    ///
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // フォーカスされた時にテキストを消せる
        searchBar.text = ""
        return true
    }
    ///
    ///
    ///
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getRepositoriesTask?.cancel()
    }
    ///
    ///
    ///
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getRepositoriesTask?.cancel()
        getRepositoriesTask = Task { [weak self] in
            do {
                guard
                    let searchResponse = try await self?.requestSearchAPI(by: searchBar.text)
                else {
                    return
                }
                self?.updateTableView(by: searchResponse.items)
            } catch let error as APIError {
                #warning("Handling error if needed")
                OSLog.loggerOfAPP.debug("🍏 Seach API error: \(error)")
                return
            } catch let error {
                if Task.isCancelled {
                    OSLog.loggerOfAPP.debug("🍏 Cancelled")
                    return
                }
                #warning("Handling error if needed")
                OSLog.loggerOfAPP.error("🍎 Unexpected response: \(error.localizedDescription)")
                return
            }
        }
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func requestSearchAPI(by searchWord: String?) async throws -> SearchResponse {
        let url = try repositoriesSearchURL(by: searchWord)
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return try validate(data: data, response: response)
    }
    ///
    ///
    ///
    private func repositoriesSearchURL(by searchWord: String?) throws -> URL {
        guard let word = searchWord, !word.isEmpty else {
            throw APIError.emptyKeyWord
        }
        guard
            let queryWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url: URL = URL(
                string: "https://api.github.com/search/repositories?q=\(queryWord)")
        else {
            throw APIError.canNotMakeRequestURL
        }
        return url
    }
    ///
    ///
    ///
    private func validate(data: Data, response: URLResponse) throws -> SearchResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other(message: "Not http response")
        }
        if try isRatelimited(of: httpResponse) {
            throw APIError.rateLimited
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.other(message: "Status code is \(httpResponse.statusCode)")
        }
        do {
            return try JSONDecoder().decode(SearchResponse.self, from: data)
        } catch let error {
            OSLog.loggerOfAPP.error("🍎 Decode exception: \(error.localizedDescription)")
            throw APIError.canNotExtractBody
        }
    }
    ///
    ///
    ///
    private func isRatelimited(of httpResponse: HTTPURLResponse) throws -> Bool {
        guard httpResponse.statusCode == 403 else {
            return false
        }
        guard
            let rateLimitRemainingValue = httpResponse.allHeaderFields["x-ratelimit-remaining"]
                as? String,
            let rateLimitRemaining = Int(rateLimitRemainingValue),
            let rateLimitResetUTCValue = httpResponse.allHeaderFields["x-ratelimit-reset"]
                as? String,
            let rateLimitResetUTC = TimeInterval(rateLimitResetUTCValue)
        else {
            throw APIError.canNotExtractHeader
        }
        if rateLimitRemaining > 0 {
            return false
        }
        OSLog.loggerOfAPP.debug(
            "🍏 rateLimitReset: \(rateLimitResetUTC - Date().timeIntervalSince1970)"
        )
        return rateLimitResetUTC > Date().timeIntervalSince1970
    }
    ///
    ///
    ///
    private func updateTableView(by repositories: [RepositorySummary]) {
        self.repositories = repositories
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
