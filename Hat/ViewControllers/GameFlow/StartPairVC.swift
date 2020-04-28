//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class StartPairVC: UIViewController {
    
    @IBOutlet weak var goButton: MyButton!
    @IBOutlet weak var tellerNameLabel: UILabel!
    
    @IBOutlet weak var helpMessage: UILabel!
    @IBOutlet weak var listenerNameLabel: UILabel!
    
    var game: GameData!
    
    var btnTimer: Timer?
    var btnTimeLeft: Int!
    
    @IBAction func goButtonTouchDown(_ sender: Any) {
        createBtnTimer(duration: K.Delays.goBtn)
        K.Sounds.countdown?.resetAndPlay()
    }
    @IBAction func goButtonTouchUp(_ sender: Any) {
        cancelBtnTimer()
        K.Sounds.countdown?.stop()
        helpMessage.isHidden = false
    }
    
    @IBAction func pressEndButton(_ sender: Any) {
        tryEndGame(title: "Закончить игру?", message: "")
    }
    
    @IBAction func unwindFromBasketVC(_ unwindSegue: UIStoryboardSegue) {
        let _ = unwindSegue.source
        checkWordsCount()
    }
    
    private func tryEndGame(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Давно пора", style: .destructive, handler: {
            action in self.showResults()
        }))
        alert.addAction(UIAlertAction(title: "Ещё поиграем", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    private func checkWordsCount() {
        title = "Осталось: \(game.leftWords.count) слов"
        if game.leftWords.count == 0 {
            showResults()
        }
    }
    private func showResults() {
        performSegue(withIdentifier: "toEndGame", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        game.startNewPair()
        tellerNameLabel.text = game.currentTeller.name
        listenerNameLabel.text = game.currentListener.name
        checkWordsCount()
        helpMessage.isHidden = true
        
        if game.isOneFullCircle() {
            tryEndGame(title: "Вы закончили полный круг", message: "Все сыграли со всеми. Закончим игру?")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay" {
            let playVC = segue.destination as? PlayVC
            playVC?.game = self.game
        } else if segue.identifier == "toEndGame" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        } else if segue.identifier == "toBasket" {
            let basketVC = segue.destination as? BasketVC
            basketVC?.game = game
        }
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
            btnTimer?.tolerance = 0.1
        }
    }
    
    func cancelBtnTimer() {
        btnTimer?.invalidate()
        btnTimer = nil
    }
}

