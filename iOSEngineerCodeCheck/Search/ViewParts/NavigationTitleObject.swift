//
//  File.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/08.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine

// MARK: -------------------- NavigationTitleObject
///
/// - Tag: NavigationTitleObject
///
final class NavigationTitleObject: ObservableObject {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    @Published var status: NavigationTitleStatus = .notSearch
}

// MARK: -------------------- NavigationTitleStatus
///
/// - Tag: NavigationTitleStatus
///
enum NavigationTitleStatus {
    case notSearch
    case searching
    case searched
}
