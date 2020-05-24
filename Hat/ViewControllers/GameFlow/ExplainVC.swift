//
//  QuestionsView.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 14.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class ExplainVC: UIViewController {
    
    var game: Game!
    var mode: Mode?
    var update: Update!
    
    var turnTimer: Timer?
    var timeLeft: Int!
    var lastTime: Int!
    
    var btnTimer: Timer?
    var btnTimeLeft: Int!
    
    var guessedQty: Int = 0
    var currentTitle: String?
    var statusTimer: Timer?
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var guessedButton: MyButton!
    @IBOutlet weak var notGuessedButton: MyButton!
    @IBOutlet weak var helpMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.lightGray]
        circleView.layer.cornerRadius = K.CircleCornerRadius.big
        lastTime = game.data.settings.roundDuration
        game.clear()
        updateTitle()
        game.explainTime = Date().convertTo(use: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        nextWord()
        createTurnTimer()
        print("\n\n\n=======START EXPLAIN=======")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noWords" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.data.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
            endGameVC?.game = game
            endGameVC?.update = update
            statusTimer?.invalidate()
        }
    }
}

// MARK: - buttons handlers
private extension ExplainVC {
    @IBAction func guessedPressed(_ sender: Any) {
        K.sounds.correct?.resetAndPlay()
        game.setWordGuessed(time: lastTime - timeLeft)
        lastTime = timeLeft
        guessedQty+=1
        updateTitle()
        nextWord()
    }
    
    @IBAction func notGuessedTouchDown(_ sender: Any) {
        notGuessedButton.backgroundColor = K.Colors.redDarker
        createBtnTimer(duration: K.Delays.notGuessedBtn)
    }
    @IBAction func notGuessedTouchUp(_ sender: Any) {
        notGuessedButton.backgroundColor = K.Colors.gray
        helpMessage.isHidden = false
        cancelBtnTimer()
    }
}

// MARK: - private functions
private extension ExplainVC {
    func updateTitle() {
        currentTitle = "Угадано: \(guessedQty) слов"
        title = currentTitle
    }
    
    func nextWord() {
        update?.setFrequent()
        if game.getRandomWordFromPool() {
            wordLabel.text = game.data.currentWord
        } else {
            cancelTurnTimer()
            
            performSegue(withIdentifier: "noWords", sender: self)
        }
    }
    
    func nextPair() {
        cancelTurnTimer()
        game.turn += 1
        if mode == .offline {
            self.navigationController?.popViewController(animated: true)
        } else {
            game.explainTime = Date().addingTimeInterval(-100000).convertTo()
            guessedButton.disable()
            notGuessedButton.disable()
                self.navigationController?.popViewController(animated: true)
        }
    }
    /*
    func updateExplainTime() {
        game.explainTime = Date().convertTo(use: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        update.setFrequent()
    }
    */
    func doNotShowWarnings(_ error: RequestError?, _ title: String? = nil) {
    }

}

// MARK: - TurnTimer
extension ExplainVC {
    @objc func updateTurnTimer() {
        timeLeft -= 1
        timerLabel.text = String(timeLeft)

        if timeLeft == 0 {
            K.sounds.timeOver?.resetAndPlay()
            game.setWordLeft(time: lastTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.nextPair()
            })
        } else if timeLeft == K.Delays.withClicks {
            K.sounds.click?.play()
            circleView.backgroundColor = K.Colors.redDarker
        } else if timeLeft < K.Delays.withClicks {
            K.sounds.click?.play()
        }
    }
    
    func createTurnTimer() {
        if turnTimer == nil {
            
            turnTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTurnTimer),
                                         userInfo: nil,
                                        repeats: true)
            turnTimer?.tolerance = 0.1
            timeLeft = game.data.settings.roundDuration
            timerLabel.text = String(timeLeft)
            //if mode != .offline { updateExplainTime() }
        }
    }
    
    func cancelTurnTimer() {
        turnTimer?.invalidate()
        turnTimer = nil
    }
}

// MARK: - BtnTimer
extension ExplainVC {
    @objc func resolveBtnTimer() {
        game.setWordMissed(time: lastTime-timeLeft)
        K.sounds.error?.play()
        nextPair()
    }
    
    func createBtnTimer(duration: Double) {
        if btnTimer == nil {
            btnTimer = Timer.scheduledTimer(timeInterval: duration,
                                         target: self,
                                         selector: #selector(resolveBtnTimer),
                                         userInfo: nil,
                                         repeats: false)
            btnTimer?.tolerance = 0.1
        }
    }
    
    func cancelBtnTimer() {
        btnTimer?.invalidate()
        btnTimer = nil
    }
}
