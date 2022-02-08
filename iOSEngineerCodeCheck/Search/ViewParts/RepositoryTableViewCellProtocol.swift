//
//  RepositoryTableViewCell.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/07.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import UIKit

// MARK: -------------------- RepositoryTableViewCellInOut
///
/// - Tag: RepositoryTableViewCellInOut
///
protocol RepositoryTableViewCellInOut: RepositoryTableViewCellInput, RepositoryTableViewCellOutput {
}

// MARK: -------------------- RepositoryTableViewCellInput
///
/// - Tag: RepositoryTableViewCellInput
///
protocol RepositoryTableViewCellInput where Self: UITableViewCell {
    ///
    func update(by summary: RepositorySummary)
}

// MARK: -------------------- RepositoryTableViewCellOutput
///
/// - Tag: RepositoryTableViewCellOutput
///
protocol RepositoryTableViewCellOutput where Self: UITableViewCell {
    ///
    var fullName: UILabel! { get set }
    ///
    var language: UILabel! { get set }
    ///
    var watchersCcount: UILabel! { get set }
    ///
    var forksCount: UILabel! { get set }
    ///
    var stargazersCount: UILabel! { get set }
}

// MARK: -------------------- RepositoryTableViewCellInput
///
///
///
extension RepositoryTableViewCellInOut {
    ///
    ///
    ///
    func update(by summary: RepositorySummary) {
        fullName.text = summary.fullName ?? "- no language -"
        language.text = summary.language ?? "- no full name -"
        watchersCcount.text = "\(summary.watchersCount ?? 0)"
        forksCount.text = "\(summary.forksCount ?? 0)"
        stargazersCount.text = "\(summary.stargazersCount ?? 0)"
    }
}
