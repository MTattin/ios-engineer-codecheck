//
//  DetailPortraitView.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/08.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import UIKit
import Combine

// MARK: -------------------- DetailPortraitView
///
/// - Tag: DetailPortraitView
///
final class DetailPortraitView: UIView, DetailViewInOut {

    // MARK: -------------------- IBOutlet
    ///
    ///
    ///
    @IBOutlet weak private(set) var scrollView: UIScrollView!
    ///
    @IBOutlet weak private(set) var avatarShadow: UIView!
    ///
    @IBOutlet weak private(set) var avatar: UIImageView!
    ///
    @IBOutlet weak private(set) var fullName: UILabel!
    ///
    @IBOutlet weak private(set) var writtenLanguage: UILabel!
    ///
    @IBOutlet weak private(set) var stargazersCount: UILabel!
    ///
    @IBOutlet weak private(set) var watchersCcount: UILabel!
    ///
    @IBOutlet weak private(set) var forksCount: UILabel!
    ///
    @IBOutlet weak private(set) var openIssuesCount: UILabel!
    ///
    @IBOutlet weak private(set) var safariLink: UIButton!

    // MARK: -------------------- Variables
    ///
    ///
    ///
    let tappedSafariLink = PassthroughSubject<Void, Never>()
    
    // MARK: -------------------- IBAction
    ///
    ///
    ///
    @IBAction func safariLinkTapped(_ sender: UIButton) {
        tappedSafariLink.send()
    }
}
