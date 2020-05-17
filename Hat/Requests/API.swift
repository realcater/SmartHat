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
    
    static func updateFrequent(game: Game, title: String? = nil,  showWarningOrTitle: @escaping warningFunc) {
        let frequentData = game.convertToFrequent()
        GameRequest.updateFrequent(for: game.id, frequentData: frequentData) { result in
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
    
    static func updateUntilSuccess(game: Game, title: String? = nil, showWarningOrTitle: @escaping warningFunc, completion: completionFunc?) {
            GameRequest.update(game: game) { result in
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
                        updateUntilSuccess(game: game, title: title, showWarningOrTitle: showWarningOrTitle, completion: completion)
                    }
                }
           }
       }
}
