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
final class RepositoryTableViewCell: UITableViewCell, RepositoryTableViewCellInOut {

    // MARK: -------------------- IBOutlet
    ///
    /// - Note: RepositoryTableViewCellOutput
    ///
    @IBOutlet weak var fullName: UILabel!
    ///
    /// - Note: RepositoryTableViewCellOutput
    ///
    @IBOutlet weak var language: UILabel!
    ///
    /// - Note: RepositoryTableViewCellOutput
    ///
    @IBOutlet weak var watchersCcount: UILabel!
    ///
    /// - Note: RepositoryTableViewCellOutput
    ///
    @IBOutlet weak var forksCount: UILabel!
    ///
    /// - Note: RepositoryTableViewCellOutput
    ///
    @IBOutlet weak var stargazersCount: UILabel!
}
