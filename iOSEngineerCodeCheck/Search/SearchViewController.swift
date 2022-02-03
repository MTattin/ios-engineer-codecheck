//
//  SearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

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
    private var getRepositoriesTask: URLSessionTask?
    ///
    private(set) var repositories: [[String: Any]] = []
    ///
    private(set) var selectedRow: Int!

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
            let detailViewController = segue.destination as? DetailViewController
        {
            detailViewController.searchViewController = self
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
        let cell = UITableViewCell()
        let rp = repositories[indexPath.row]
        cell.textLabel?.text = rp["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = rp["language"] as? String ?? ""
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
        // Cellがタップされた時に呼ばれる
        selectedRow = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
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
        guard let url: URL = self.repositoriesSearchURL(by: searchBar.text) else {
            return
        }
        getRepositoriesTask = URLSession.shared.dataTask(with: url) {
            [weak self] (data, res, err) in
            self?.updateRepositories(by: data)
        }
        // リクエスト開始
        getRepositoriesTask?.resume()
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func repositoriesSearchURL(by searchWord: String?) -> URL? {
        guard
            let word: String = searchWord,
            let url: URL = URL(string: "https://api.github.com/search/repositories?q=\(word)")
        else {
            return nil
        }
        return url
    }
    ///
    ///
    ///
    private func updateRepositories(by data: Data?) {
        guard
            let data = data,
            let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            #warning("Need some action")
            return
        }
        guard let items: [[String: Any]] = dictionary["items"] as? [[String: Any]] else {
            return
        }
        self.repositories = items
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
