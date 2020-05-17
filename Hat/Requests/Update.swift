//
//  UpdateData.swift
//  Hat
//
//  Created by Realcater on 15.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

class Update {

    typealias warningFunc = (_ error: RequestError?, _ title: String?) -> Void
    typealias completionFunc = () -> Void
    
    var attempts = 1
    
    func frequent(game: Game, title: String? = nil,  showWarningOrTitle: @escaping warningFunc) {
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
    
    func fullUntilSuccess(game: Game, title: String? = nil, showWarningOrTitle: @escaping warningFunc, completion: completionFunc?) {
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
                        if (error == .noConnection) && self.attempts < Int(K.Server.Time.ttlTryTime / K.Server.Time.waitUntilNextTry) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + K.Server.Time.waitUntilNextTry) {
                                self.attempts += 1
                                self.fullUntilSuccess(game: game, title: title, showWarningOrTitle: showWarningOrTitle, completion: completion)
                            }
                        } else {
                            if let completion = completion { completion() }
                            return
                        }
                    }
                }
           }
       }
}
