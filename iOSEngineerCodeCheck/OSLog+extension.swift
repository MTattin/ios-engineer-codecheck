//
//  OSLog+extension.swift
//  iOSEngineerCodeCheck
//
//  Created by Masakiyo Tachikawa on 2022/02/04.
//  Copyright © 2022 YUMEMI Inc. All rights reserved.
//

import os

extension OSLog {

    // MARK: -------------------- Variables
    ///
    /// APP用のロガー
    ///
    /// ```
    /// import os
    ///
    /// OSLog.loggerOfAPP.error("Error description")
    /// OSLog.loggerOfAPP.info("Information message")
    /// ```
    ///
    /// - Tag: loggerOfAPP
    ///
    static let loggerOfAPP = Logger(subsystem: "jp.yumemi.iOSEngineerCodeCheck", category: "iOSEngineerCodeCheck")
}
