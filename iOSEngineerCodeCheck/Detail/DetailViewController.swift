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
    weak var searchViewController: SearchViewController!

    // MARK: -------------------- Lifecycle
    ///
    ///
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        let repo = searchViewController.repositories[searchViewController.selectedRow]
        writtenLanguage.text = "Written in \(repo["language"] as? String ?? "")"
        stargazersCount.text = "\(repo["stargazers_count"] as? Int ?? 0) stars"
        wachersCcount.text = "\(repo["wachers_count"] as? Int ?? 0) watchers"
        forksCount.text = "\(repo["forks_count"] as? Int ?? 0) forks"
        openIssuesCount.text = "\(repo["open_issues_count"] as? Int ?? 0) open issues"
        setOwnerInformation()
    }

    // MARK: -------------------- Conveniences
    ///
    ///
    ///
    private func setOwnerInformation() {
        let repo = searchViewController.repositories[searchViewController.selectedRow]
        fullName.text = repo["full_name"] as? String
        guard
            let owner = repo["owner"] as? [String: Any],
            let avaterURLString = owner["avatar_url"] as? String,
            let avaterURL = URL(string: avaterURLString)
        else {
            return
        }
        URLSession.shared.dataTask(with: avaterURL) { [weak self] (data, res, err) in
            self?.recevieAvatarResponse(data)
        }.resume()
    }
    ///
    ///
    ///
    private func recevieAvatarResponse(_ data: Data?) {
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
