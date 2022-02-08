//
//  NavigationTitleView.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/08.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import Combine
import SwiftUI

// MARK: -------------------- NavigationTitleView
///
/// - Tag: NavigationTitleView
///
struct NavigationTitleView: View {

    // MARK: -------------------- Variables
    ///
    ///
    ///
    let title: String
    ///
    @ObservedObject var object: NavigationTitleObject

    // MARK: -------------------- Views
    ///
    ///
    ///
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title).background(Color.clear)
                .foregroundColor(Color.white)
            Image("octopus", bundle: nil)
                .frame(width: 32.0, height: 32.0)
                .foregroundColor(
                    (object.status == .notSearch)
                        ? Color.white
                        : (object.status == .searching) ? Color.yellow : Color.red)
        }
    }
}
