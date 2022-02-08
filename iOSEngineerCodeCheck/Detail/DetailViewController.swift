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

    // MARK: -------------------- Variables
    ///
    ///
    ///
    private var cancellables = Set<AnyCancellable>()
    ///
    private var detailPresenter: DetailPresenterInOut
    ///
    private let containerView: UIView = UIView()
    ///
    private var detailPortraitView: DetailPortraitView?
    ///
    private var detailLandscapeView: DetailLandscapeView?
    ///
    private var summary: RepositorySummary?
    ///
    private var avatarImage: UIImage?
    ///
    private var cancellableSarafiTapped: AnyCancellable?

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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.clear
        view.addSubview(containerView)
        view.bringSubviewToFront(containerView)
        NSLayoutConstraint(
            item: view.safeAreaLayoutGuide, attribute: .top, relatedBy: .equal,
            toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: view.safeAreaLayoutGuide, attribute: .bottom, relatedBy: .equal,
            toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: view.safeAreaLayoutGuide, attribute: .left, relatedBy: .equal,
            toItem: containerView, attribute: .left, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: view.safeAreaLayoutGuide, attribute: .right, relatedBy: .equal,
            toItem: containerView, attribute: .right, multiplier: 1.0, constant: 0.0
        ).isActive = true
        makeDetailFit(size: view.frame.size)
        detailPresenter.viewDidLoad()
    }
    ///
    ///
    ///
    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        makeDetailFit(size: size)
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func makeDetailFit(size: CGSize) {
        self.detailLandscapeView?.removeFromSuperview()
        self.detailPortraitView?.removeFromSuperview()
        if size.width > size.height {
            makeDetailLandscapeView()
        } else {
            makeDetailPortraitView()
        }
    }
    ///
    ///
    ///
    private func makeDetailPortraitView() {
        if detailPortraitView == nil {
            detailPortraitView =
                UINib(nibName: "DetailPortraitView", bundle: nil).instantiate(
                    withOwner: nil, options: nil
                ).first as? DetailPortraitView
            detailPortraitView?.viewDidLoad()
        }
        updateDetailLayout(of: detailPortraitView!)
    }
    ///
    ///
    ///
    private func makeDetailLandscapeView() {
        if detailLandscapeView == nil {
            detailLandscapeView =
                UINib(nibName: "DetailLandscapeView", bundle: nil).instantiate(
                    withOwner: nil, options: nil
                ).first as? DetailLandscapeView
            detailLandscapeView?.viewDidLoad()
        }
        updateDetailLayout(of: detailLandscapeView!)
    }
    ///
    ///
    ///
    private func updateDetailLayout<T: DetailViewInOut>(of detail: T) {
        detail.avatar.image = avatarImage
        detail.setDetail(by: summary)
        detail.add(at: containerView)
        detail.viewDidAppear()
        cancellableSarafiTapped?.cancel()
        cancellableSarafiTapped = detail.tappedSafariLink
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.openLinkInSafari()
            }
    }
    ///
    ///
    ///
    private func openLinkInSafari() {
        guard
            let urlString = self.summary?.htmlURL,
            let url = URL(string: urlString)
        else {
            self.view.makeToast(
                NSLocalizedString("open.html.url.failed", comment: ""),
                duration: 5.0,
                position: .top
            )
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        self.summary = summary
        detailPortraitView?.setDetail(by: summary)
        detailLandscapeView?.setDetail(by: summary)
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
        self.avatarImage = avatarImage
        detailPortraitView?.avatar.image = avatarImage
        detailLandscapeView?.avatar.image = avatarImage
    }
}
