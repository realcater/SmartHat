//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class StartPairVC: UIViewController {
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var goButton: MyButton!
    @IBOutlet weak var tellerNameLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var helpMessage: UILabel!
    @IBOutlet weak var listenerNameLabel: UILabel!
    
    var game: Game!
    var btnTimer: Timer?
    var btnTimeLeft: Int!
    var dataTimer: Timer?
    var turnTimer: Timer?
    var statusTimer: Timer?
    var timeLeft: Int!
    var mode: Mode?
    var firstTurnAfterLoad = true
    var currentTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        circleView.layer.cornerRadius = K.CircleCornerRadius.small
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        prepareNewTurn(colorise: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        coloriseBarView()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay" {
            let playVC = segue.destination as? PlayVC
            playVC?.game = self.game
            playVC?.mode = self.mode
            //playVC?.statusTimer = statusTimer
            cancelDataTimer()
        } else if segue.identifier == "toEndGame" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.data.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
            cancelDataTimer()
            statusTimer?.invalidate()
        } else if segue.identifier == "toBasket" {
            let basketVC = segue.destination as? BasketVC
            basketVC?.game = game
            basketVC?.editable = game.userOwnerID == Auth().id
        }
    }
}

// MARK: - buttons handlers
extension StartPairVC {
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
        if mode == Mode.offline {
            tryEndGame()
        } else if game.userOwnerID == Auth().id {
            tryEndOrQuitGame()
        } else {
            tryQuitGame()
        }
    }
    
    @IBAction func unwindFromBasketVC(_ unwindSegue: UIStoryboardSegue) {
        let _ = unwindSegue.source
        checkWordsCount()
    }
    @IBAction func pressBasketButton(_ sender: Any) {
        performSegue(withIdentifier: "toBasket", sender: self)
    }
}

// MARK: - private functions
extension StartPairVC {
    var isMyTurn: Bool { //always true if offline game)
        return (mode == .offline) || (game.currentTeller.id == Auth().id)
    }
    var isTeller: Bool {
        return game.currentTeller.id == Auth().id
    }
    var isListener: Bool {
        return game.currentListener.id == Auth().id
    }
    func coloriseBarView() {
        if isTeller {
            barView.makeDoubleColor(leftColor: K.Colors.red80, rightColor: K.Colors.foreground80)
        } else if isListener {
            barView.makeDoubleColor(leftColor: K.Colors.foreground80, rightColor: K.Colors.red80)
        } else {
            barView.backgroundColor = K.Colors.foreground80
            barView.removeDoubleColor()
        }
    }
    
    var anotherPlayerIsGuessing: Bool {
        return turnTimer != nil
    }
    
    func reloadNames() {
        tellerNameLabel.text = game.currentTeller.name
        listenerNameLabel.text = game.currentListener.name
    }
    
    func prepareNewTurn(colorise: Bool = true) {
        if colorise { coloriseBarView() }
        reloadNames()
        checkWordsCount()
        helpMessage.isHidden = true
        
        if mode != .offline { createDataTimer() }
        if isMyTurn {
            if game.isOneFullCircle {
                if firstTurnAfterLoad { firstTurnAfterLoad = false } else {
                    tryEndGame(title: "Вы закончили полный круг", message: "Все сыграли со всеми. Закончим игру?")
                }
            }
            circleView.isHidden = true
            timerLabel.isHidden = true
            goButton.enable()
        } else {
            goButton.disable()
            circleView.isHidden = false
            circleView.backgroundColor = K.Colors.foreground40
            timerLabel.isHidden = false
            timeLeft = game.data.settings.roundDuration
            timerLabel.text = String(timeLeft)
        }
    }
    
    func updateTitle() {
        if anotherPlayerIsGuessing {
            currentTitle = "Угадано: \(game.guessedThisTurn) слов"
            if title != currentTitle { title = currentTitle }
        } else {
            checkWordsCount()
        }
    }
    func checkWordsCount() {
        currentTitle = "Осталось: \(game.data.leftWords.count) слов"
        if title != currentTitle { title = currentTitle }
        if game.data.leftWords.count == 0 {
            showResults()
        }
    }
    func showResults() {
        game.turn = K.endTurnNumber
        cancelDataTimer()
        if mode == .offline {
            performSegue(withIdentifier: "toEndGame", sender: self)
        } else {
            Update().fullUntilSuccess(game: game, showWarningOrTitle: self.showWarningOrTitle) { self.performSegue(withIdentifier: "toEndGame", sender: self) }
        }
    }
}
