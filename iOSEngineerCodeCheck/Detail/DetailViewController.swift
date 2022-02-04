//
//  DetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

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
    @IBOutlet weak private var wachersCcount: UILabel!
    ///
    @IBOutlet weak private var forksCount: UILabel!
    ///
    @IBOutlet weak private var openIssuesCount: UILabel!

    // MARK: -------------------- Variables
    ///
    ///
    ///
    var repository: [String: Any] = [:]

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        writtenLanguage.text = "Written in \(repository["language"] as? String ?? "")"
        stargazersCount.text = "\(repository["stargazers_count"] as? Int ?? 0) stars"
        wachersCcount.text = "\(repository["watchers_count"] as? Int ?? 0) watchers"
        forksCount.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        openIssuesCount.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        setOwnerInformation()
    }
    ///
    ///
    ///
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollView.flashScrollIndicators()
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func setOwnerInformation() {
        fullName.text = repository["full_name"] as? String
        guard
            let owner = repository["owner"] as? [String: Any],
            let avaterURLString = owner["avatar_url"] as? String,
            let avaterURL = URL(string: avaterURLString)
        else {
            return
        }
        Task { [weak self] in
            do {
                guard let image = try await self?.loadAvatar(from: avaterURL) else {
                    return
                }
                self?.setImage(to: image)
            } catch let error as APIError {
                #warning("Handling error if needed")
                OSLog.loggerOfAPP.debug("🍏 Avatar API error: \(error)")
                return
            } catch let error {
                #warning("Handling error if needed")
                OSLog.loggerOfAPP.error("🍎 Unexpected response: \(error.localizedDescription)")
                return
            }
        }
    }
    ///
    ///
    ///
    private func loadAvatar(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        return try self.validate(data: data, response: response)
    }
    ///
    ///
    ///
    private func validate(data: Data, response: URLResponse) throws -> UIImage {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.other(message: "Not http response")
        }
        guard httpResponse.statusCode == 200 else {
            throw APIError.other(message: "Status code is \(httpResponse.statusCode)")
        }
        guard let avatar = UIImage(data: data) else {
            throw APIError.notImageData
        }
        return avatar
    }
    ///
    ///
    ///
    private func setImage(to avatar: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.avatar.image = avatar
        }
    }
}
