//
//  QuestionsView.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 14.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class PlayVC: UIViewController {
    @IBOutlet weak var wordLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var guessed: MyButton!
    @IBOutlet weak var notGuessed: MyButton!
    
    @IBAction func guessedPressed(_ sender: Any) {
        game.setGuessed(word)
        K.Sounds.correct?.play()
        nextWord()
    }
    
    @IBAction func notGuessedPressed(_ sender: Any) {
        nextPair()
    }
    
    var game: Game!
    var word = ""
    var timer: Timer?
    var timeLeft: Int!
    
    private func prepareButtons() {
        guessed.makeRounded(color: K.Colors.foreground, textColor: K.Colors.background, sound: K.Sounds.click)
        notGuessed.makeRounded(color: UIColor.red, textColor: K.Colors.background, sound: K.Sounds.click)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        prepareButtons()
        title = game.currentTeller.name + "  >>  " + game.currentListener.name
        nextWord()
        createTimer()
        
    }
    private func nextWord() {
        word = game.getRandomWordFromPool()
        wordLabel.text = word
    }
    
    private func nextPair() {
        cancelTimer()
        K.Sounds.error?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            _ = self.navigationController?.popViewController(animated: true)
        })
    }

}

// MARK: - Timer
extension PlayVC {
    @objc func updateTimer() {
        timeLeft -= 1
        timerLabel.text = String(timeLeft)
        if timeLeft <= K.timeWithClicks { K.Sounds.click?.play() }
        if timeLeft == 0 {
            K.Sounds.error?.play()
            nextPair()
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
