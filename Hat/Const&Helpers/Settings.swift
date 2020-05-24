//
//  Settings.swift
//  Hat
//
//  Created by Realcater on 24.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

struct Settings {
    static var clientSettings = ClientSettings(
        updatePlayersStatus: 5.0,
        updateGameList: 5.0,
        checkOffline: 10.0,
        updateFrequent: 1.0,
        updateFullTillNextTry: 1.0)
}
