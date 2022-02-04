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
    private(set) var repositories: [[String: Any]] = []

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail",
            let detailViewController = segue.destination as? DetailViewController,
            let selectedIndex = sender as? IndexPath
        {
            detailViewController.repository = repositories[selectedIndex.row]
        }
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
            cell = UITableViewCell()
        }
        cell.textLabel?.text = repositories[indexPath.row]["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = repositories[indexPath.row]["language"] as? String ?? ""
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
        performSegue(withIdentifier: "Detail", sender: indexPath)
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
                    let repositories = try await self?.requestSearchAPI(by: searchBar.text)
                else {
                    return
                }
                self?.updateTableView(by: repositories)
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
    private func requestSearchAPI(by searchWord: String?) async throws -> [[String: Any]] {
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
    private func validate(data: Data, response: URLResponse) throws -> [[String: Any]] {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other(message: "Not http response")
        }
        if try isRatelimited(of: httpResponse) {
            throw APIError.rateLimited
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.other(message: "Status code is \(httpResponse.statusCode)")
        }
        return try self.makeRepositoriesArray(by: data)
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
    private func makeRepositoriesArray(by data: Data?) throws -> [[String: Any]] {
        guard
            let data = data,
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let items: [[String: Any]] = dictionary["items"] as? [[String: Any]]
        else {
            throw APIError.canNotExtractBody
        }
        return items
    }
    ///
    ///
    ///
    private func updateTableView(by repositories: [[String: Any]]) {
        self.repositories = repositories
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
