//
//  DetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Combine
import Toast
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
    @IBOutlet weak private var avatarShadow: UIView!
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
        sinkDetailPresenterOutput()
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
        let baseSize = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        avatar.layer.cornerRadius = baseSize * 0.16
        avatarShadow.layer.cornerRadius = baseSize * 0.16
        avatarShadow.layer.shadowColor = UIColor.black.cgColor
        avatarShadow.layer.shadowRadius = baseSize * 0.04
        avatarShadow.layer.shadowOffset = CGSize(width: 0.0, height: baseSize * 0.02)
        avatarShadow.layer.shadowOpacity = 0.5
        detailPresenter.viewDidLoad()
        avatar.accessibilityIdentifier = "avatar.DetailViewController"
        fullName.accessibilityIdentifier = "fullName.DetailViewController"
        writtenLanguage.accessibilityIdentifier = "writtenLanguage.DetailViewController"
        stargazersCount.accessibilityIdentifier = "stargazersCount.DetailViewController"
        watchersCcount.accessibilityIdentifier = "watchersCcount.DetailViewController"
        forksCount.accessibilityIdentifier = "forksCount.DetailViewController"
        openIssuesCount.accessibilityIdentifier = "openIssuesCount.DetailViewController"
    }
    ///
    ///
    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
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
            .store(in: &cancellables)
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
            .store(in: &cancellables)
    }
    ///
    ///
    ///
    private func setDetail(by summary: RepositorySummary) {
        writtenLanguage.text = summary.writtenLanguage
        stargazersCount.text = summary.stargazers
        watchersCcount.text = summary.watchers
        forksCount.text = summary.forks
        openIssuesCount.text = summary.openIssues
        fullName.text = summary.fullName
    }
    ///
    ///
    ///
    private func loadAvatarFailed(by error: APIError) {
        if error == .cancelled {
            return
        }
        self.view.makeToast(
            NSLocalizedString("loadAvatar.failed", comment: ""),
            duration: 3.0,
            position: .top
        )
    }
    ///
    ///
    ///
    private func setImage(to avatarImage: UIImage) {
        avatar.image = avatarImage
    }
}
