//
//  UpdateData.swift
//  Hat
//
//  Created by Realcater on 15.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

class API {

    typealias warningFunc = (_ error: RequestError?, _ title: String?) -> Void
    typealias completionFunc = () -> Void
    
    static func updateFrequent(gameID: UUID, gameData: GameData, title: String? = nil,  showWarningOrTitle: @escaping warningFunc) {
        let frequentGameData = FrequentGameData(explainTime: gameData.explainTime, turn: gameData.turn, guessedThisTurn: gameData.guessedThisTurn)
        GameRequest.updateFrequent(for: gameID, frequentGameData: frequentGameData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showWarningOrTitle(nil, title)
                case .failure(let error):
                    showWarningOrTitle(error, nil)
                }
            }
        }
    }
    
    static func tryUpdate(gameID: UUID, gameData: GameData, title: String? = nil, showWarningOrTitle: @escaping warningFunc, completion: @escaping completionFunc) {
        GameRequest.update(for: gameID, gameData: gameData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showWarningOrTitle(nil, title)
                case .failure(let error):
                    showWarningOrTitle(error, nil)
                }
            }
        }
    }
    static func updateUntilSuccess(gameID: UUID, gameData: GameData, title: String? = nil, showWarningOrTitle: @escaping warningFunc, completion: completionFunc?) {
            GameRequest.update(for: gameID, gameData: gameData) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        showWarningOrTitle(nil, title)
                        if let completion = completion { completion() }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        showWarningOrTitle(error, nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + K.Server.Time.waitUntilNextTry) {
                        updateUntilSuccess(gameID: gameID, gameData: gameData, title: title, showWarningOrTitle: showWarningOrTitle, completion: completion)
                    }
                }
           }
       }
}
