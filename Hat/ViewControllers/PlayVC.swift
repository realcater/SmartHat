//
//  QuestionsView.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 14.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class PlayVC: UIViewController {
    
    var game: Game!
    var timer: Timer?
    var timeLeft: Int!
    
    var btnTimer: Timer?
    var btnTimeLeft: Int!
    
    var guessedQty: Int = 0
    
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var guessedButton: MyButton!
    @IBOutlet weak var notGuessedButton: MyButton!
    @IBOutlet weak var endTurnButton: MyButton!
    
    @IBOutlet weak var helpMessage: UILabel!
    
    @IBAction func guessedPressed(_ sender: Any) {
        K.Sounds.correct?.resetAndPlay()
        game.setWordGuessed()
        
        guessedQty+=1
        updateTitle()
        
        nextWord()
    }

    @IBAction func endTurnButtonPressed(_ sender: Any) {
        game.setWordLeft()
        nextPair()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.lightGray]
        circleView.layer.cornerRadius = 40
        game.basketWords = []
        game.basketStatus = []
        updateTitle()
        nextWord()
        createTimer()
    }

    private func updateTitle() {
        title = "Угадано: \(guessedQty) слов"
    }
    
    private func nextWord() {
        if game.getRandomWordFromPool() {
             wordLabel.text = game.currentWord
        } else {
            cancelTimer()
            performSegue(withIdentifier: "noWords", sender: self)
        }
    }
    
    private func nextPair() {
        cancelTimer()
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noWords" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        }
    }

}

// MARK: - Timer
extension PlayVC {
    @objc func updateTimer() {
        timeLeft -= 1
        timerLabel.text = String(timeLeft)

        if timeLeft == 0 {
            K.Sounds.timeOver?.resetAndPlay()
            circleView.backgroundColor = K.Colors.redDarker
            warningView.isHidden = false
        } else if timeLeft == -1*K.secsAfter {
            K.Sounds.timeOver?.resetAndPlay()
            game.setWordLeft()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.nextPair()
            })
        } else if timeLeft <= K.Delays.withClicks {
            K.Sounds.click?.play()
            endTurnButton.isHidden = false
            
            
        }
    }
    
    func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(updateTimer),
                                         userInfo: nil,
                                        repeats: true)
            timer?.tolerance = 0.1
            timeLeft = game.time
            timerLabel.text = String(timeLeft)
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Timer
extension PlayVC {
    @objc func resolveBtnTimer() {
        game.setWordMissed()
        K.Sounds.error?.play()
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
