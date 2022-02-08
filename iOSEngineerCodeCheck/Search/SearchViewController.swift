//
//  SearchViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import SwiftUI
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
    ///
    private let navigationTitleObject = NavigationTitleObject()

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
        self.title = NSLocalizedString("search.navigation.title", comment: "")
        let titleHostingController = UIHostingController(
            rootView: NavigationTitleView(title: self.title!, object: navigationTitleObject)
        )
        titleHostingController.view.backgroundColor = UIColor.clear
        self.navigationItem.titleView = titleHostingController.view
        searchBar.placeholder = NSLocalizedString("searchBar.placeholder", comment: "")
        searchBar.delegate = self
        tableView.register(
            UINib(nibName: "RepositoryTableViewCell", bundle: nil),
            forCellReuseIdentifier: "RepositoryTableViewCell")
        searchBar.searchTextField.accessibilityIdentifier =
            "searchBar.searchTextField.SearchViewController"
        tableView.accessibilityIdentifier = "tableView.SearchViewController"
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
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80.0
    }
    ///
    ///
    ///
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: RepositoryTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell")
            as! RepositoryTableViewCell
        cell.fullName.text = searchPresenter.repositories[indexPath.row].fullName ?? ""
        cell.language.text = searchPresenter.repositories[indexPath.row].language ?? ""
        cell.watchersCcount.text =
            "\(searchPresenter.repositories[indexPath.row].watchersCount ?? 0)"
        cell.forksCount.text = "\(searchPresenter.repositories[indexPath.row].forksCount ?? 0)"
        cell.stargazersCount.text =
            "\(searchPresenter.repositories[indexPath.row].stargazersCount ?? 0)"
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
        navigationTitleObject.status = (searchBar.text?.isEmpty ?? true) ? .notSearch : .searching
    }
    ///
    ///
    ///
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        navigationTitleObject.status = (searchBar.text?.isEmpty ?? true) ? .notSearch : .searching
        searchBar.resignFirstResponder()
        if searchBar.text?.isEmpty ?? true {
            self.view.makeToast(
                NSLocalizedString("searchBar.text.isEmpty", comment: ""),
                duration: 3.0,
                position: .top
            )
            navigationTitleObject.status = .notSearch
            return
        }
        self.navigationController?.view.makeToastActivity(.center)
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
                self?.navigationController?.view.hideToastActivity()
                if let error = error {
                    self?.loadRepositoriesFailed(by: error)
                    return
                }
                self?.tableView.reloadData()
                self?.navigationTitleObject.status = .searched
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
        navigationTitleObject.status = (searchBar?.text?.isEmpty ?? true) ? .notSearch : .searching
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
        case .invalidRequestQuery(let reason):
            self.view.makeToast(
                reason.toastMessage,
                duration: 5.0,
                position: .top
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
