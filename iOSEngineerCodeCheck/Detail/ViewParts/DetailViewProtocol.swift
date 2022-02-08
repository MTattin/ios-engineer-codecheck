//
//  DetailViewProtocol.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/08.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import UIKit
import Combine

// MARK: -------------------- DetailViewInOut
///
/// - Tag: DetailViewInOut
///
protocol DetailViewInOut: DetailViewInput, DetailViewOutput {}

// MARK: -------------------- DetailViewInput
///
/// - Tag: DetailViewInput
///
protocol DetailViewInput where Self: UIView {
    ///
    func viewDidLoad()
    ///
    func viewDidAppear()
    ///
    func setDetail(by summary: RepositorySummary?)
    ///
    func add(at superView: UIView)
}

// MARK: -------------------- DetailViewOutput
///
/// - Tag: DetailViewOutput
///
protocol DetailViewOutput where Self: UIView {
    ///
    var scrollView: UIScrollView! { get }
    ///
    var avatarShadow: UIView! { get }
    ///
    var avatar: UIImageView! { get }
    ///
    var fullName: UILabel! { get }
    ///
    var writtenLanguage: UILabel! { get }
    ///
    var stargazersCount: UILabel! { get }
    ///
    var watchersCcount: UILabel! { get }
    ///
    var forksCount: UILabel! { get }
    ///
    var openIssuesCount: UILabel! { get }
    ///
    var safariLink: UIButton! { get }
    ///
    var tappedSafariLink: PassthroughSubject<Void, Never> { get }
}

// MARK: -------------------- DetailViewInupt
///
///
///
extension DetailViewInOut {
    ///
    ///
    ///
    func viewDidLoad() {
        let baseSize = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        avatar.layer.cornerRadius = baseSize * 0.16
        avatarShadow.layer.cornerRadius = baseSize * 0.16
        avatarShadow.layer.shadowColor = UIColor.black.cgColor
        avatarShadow.layer.shadowRadius = baseSize * 0.04
        avatarShadow.layer.shadowOffset = CGSize(width: 0.0, height: baseSize * 0.02)
        avatarShadow.layer.shadowOpacity = 0.5
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
    func viewDidAppear() {
        scrollView.flashScrollIndicators()
    }
    ///
    ///
    ///
    func setDetail(by summary: RepositorySummary?) {
        guard let summary = summary else {
            return
        }
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
    func add(at superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        superView.addSubview(self)
        superView.bringSubviewToFront(self)
        NSLayoutConstraint(
            item: superView, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: superView, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: superView, attribute: .left, relatedBy: .equal,
            toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0
        ).isActive = true
        NSLayoutConstraint(
            item: superView, attribute: .right, relatedBy: .equal,
            toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0
        ).isActive = true
    }
}
