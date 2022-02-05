//
//  SearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import Toast
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
    private var cancellables = Set<AnyCancellable>()
    ///
    private var searchPresenter: SearchPresenterInOut

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init?(coder: NSCoder, presenter: SearchPresenterInOut) {
        searchPresenter = presenter
        super.init(coder: coder)
        sinkSearchPresenterOutput()
    }
    ///
    ///
    ///
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "")
        searchBar.delegate = self
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
        return searchPresenter.repositories.count
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
        cell.textLabel?.text = searchPresenter.repositories[indexPath.row].fullName ?? ""
        cell.detailTextLabel?.text = searchPresenter.repositories[indexPath.row].language ?? ""
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
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        searchPresenter.tapCell(at: indexPath)
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchPresenter.cancelSearch()
    }
    ///
    ///
    ///
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text?.isEmpty ?? true {
            self.view.makeToast(
                NSLocalizedString("searchBar.text.isEmpty", comment: ""),
                duration: 3.0,
                position: .top
            )
            return
        }
        searchPresenter.search(by: searchBar.text)
    }
}

// MARK: -------------------- SearchPresenterOutput
///
///
///
extension SearchViewController {
    ///
    ///
    ///
    private func sinkSearchPresenterOutput() {
        searchPresenter.didLoadRepositories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.loadRepositoriesFailed(by: error)
                    return
                }
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        searchPresenter.didTappedCell
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summary in
                self?.pushDetailViewController(using: summary)
            }
            .store(in: &cancellables)
    }
    ///
    ///
    ///
    private func loadRepositoriesFailed(by error: APIError) {
        switch error {
        case .cancelled:
            return
        case .rateLimited(let rateLimit):
            self.view.makeToast(
                rateLimit.makeErrorMessage(),
                duration: 5.0,
                position: .top,
                title: NSLocalizedString("search.rateLimited.title", comment: "")
            )
            return

        default:
            self.view.makeToast(
                NSLocalizedString("search.failed", comment: ""),
                duration: 3.0,
                position: .top
            )
            return
        }
    }
    ///
    ///
    ///
    private func pushDetailViewController(using summary: RepositorySummary) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
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
