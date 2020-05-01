//
//  Environment.swift
//  Hat
//
//  Created by Realcater on 30.04.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

public enum Environment {
    static let appKey: String = {
        guard let appKey = ProcessInfo.processInfo.environment["appKey"] else {
            fatalError("AppKey not set in this environment")
        }
      return appKey
    }()
}
