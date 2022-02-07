//
//  RepositoryTableViewCell.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/07.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import UIKit

// MARK: -------------------- RepositoryTableViewCell
///
/// GitHubのリポジトリ検索画面のセル
///
/// - Tag: RepositoryTableViewCell
///
class RepositoryTableViewCell: UITableViewCell {

    // MARK: -------------------- IBOutlet
    ///
    ///
    ///
    @IBOutlet weak var fullName: UILabel!
    ///
    @IBOutlet weak var language: UILabel!
    ///
    @IBOutlet weak var watchersCcount: UILabel!
    ///
    @IBOutlet weak var forksCount: UILabel!
    ///
    @IBOutlet weak var stargazersCount: UILabel!
}
