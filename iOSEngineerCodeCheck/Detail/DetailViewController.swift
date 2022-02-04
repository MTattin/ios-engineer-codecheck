//
//  DetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import UIKit
import os

// MARK: -------------------- DetailViewController
///
/// GitHubのリポジトリ詳細画面
///
/// - Tag: DetailViewController
///
final class DetailViewController: UIViewController {

    // MARK: -------------------- IBOutlet
    ///
    ///
    ///
    @IBOutlet weak private var scrollView: UIScrollView!
    ///
    @IBOutlet weak private var avatar: UIImageView!
    ///
    @IBOutlet weak private var fullName: UILabel!
    ///
    @IBOutlet weak private var writtenLanguage: UILabel!
    ///
    @IBOutlet weak private var stargazersCount: UILabel!
    ///
    @IBOutlet weak private var watchersCcount: UILabel!
    ///
    @IBOutlet weak private var forksCount: UILabel!
    ///
    @IBOutlet weak private var openIssuesCount: UILabel!

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private var cancellables = Set<AnyCancellable>()
    ///
    private var detailPresenter: DetailPresenterInOut

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    init?(coder: NSCoder, presenter: DetailPresenterInOut) {
        detailPresenter = presenter
        super.init(coder: coder)
        self.sinkDetailPresenterOutput()
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
        detailPresenter.viewDidLoad()
    }
    ///
    ///
    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollView.flashScrollIndicators()
    }
}

// MARK: -------------------- DetailPresenterOutput
///
///
///
extension DetailViewController {
    ///
    ///
    ///
    private func sinkDetailPresenterOutput() {
        detailPresenter.didLoadRepositorySummary
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summary in
                self?.setDetail(by: summary)
            }
            .store(in: &self.cancellables)
        detailPresenter.didLoadAvatar
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.loadAvatarFailed(by: error)
                    }
                },
                receiveValue: { [weak self] avatar in
                    self?.setImage(to: avatar)
                }
            )
            .store(in: &self.cancellables)
    }
    ///
    ///
    ///
    private func setDetail(by summary: RepositorySummary) {
        self.writtenLanguage.text = summary.writtenLanguage
        self.stargazersCount.text = summary.stargazers
        self.watchersCcount.text = summary.watchers
        self.forksCount.text = summary.forks
        self.openIssuesCount.text = summary.openIssues
        self.fullName.text = summary.fullName
    }
    ///
    ///
    ///
    private func loadAvatarFailed(by error: APIError) {
        #warning("Handling error if needed")
    }
    ///
    ///
    ///
    private func setImage(to avatar: UIImage) {
        self.avatar.image = avatar
    }
}
