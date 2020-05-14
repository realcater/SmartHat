//
//  +timers.swift
//  Hat
//
//  Created by Realcater on 13.05.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import Foundation

// MARK: - TurnTimer
extension StartPairVC {
    @objc func updateTurnTimer() {
        timeLeft -= 1
        timerLabel.text = String(timeLeft)
        if timeLeft <= 0 {
            cancelTurnTimer()
        } else if timeLeft == K.Delays.withClicks {
            circleView.backgroundColor = K.Colors.red40
        }
    }
    
    func createTurnTimer(timeLeft:Int) {
        self.timeLeft = timeLeft
        if turnTimer == nil {
            turnTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTurnTimer),
                                         userInfo: nil,
                                        repeats: true)
            turnTimer?.tolerance = 0.1
        }
        
    }
    func cancelTurnTimer() {
        turnTimer?.invalidate()
        turnTimer = nil
    }
}

// MARK: - BtnTimer
extension StartPairVC {
    @objc func resolveBtnTimer() {
        cancelBtnTimer()
        performSegue(withIdentifier: "toPlay", sender: self)
    }
    
    func createBtnTimer(duration: Double) {
        if btnTimer == nil {
            btnTimer = Timer.scheduledTimer(timeInterval: duration,
                                            target: self,
                                            selector: #selector(resolveBtnTimer),
                                            userInfo: nil,
                                            repeats: false)
            btnTimer?.tolerance = 0.01
        }
    }
    
    func cancelBtnTimer() {
        btnTimer?.invalidate()
        btnTimer = nil
    }
}

