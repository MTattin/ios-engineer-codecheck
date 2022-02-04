//
//  DetailViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

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
        wachersCcount.text = "\(repository["wachers_count"] as? Int ?? 0) watchers"
        forksCount.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        openIssuesCount.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        setOwnerInformation()
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
        URLSession.shared.dataTask(with: avaterURL) { [weak self] (data, res, err) in
            self?.setAvatar(by: data)
        }.resume()
    }
    ///
    ///
    ///
    private func setAvatar(by data: Data?) {
        guard
            let data = data,
            let avatar = UIImage(data: data)
        else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.avatar.image = avatar
        }
    }
}
