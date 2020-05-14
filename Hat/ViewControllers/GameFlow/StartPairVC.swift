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
    
    var gameData: GameData!
    var gameID: UUID?
    var btnTimer: Timer?
    var btnTimeLeft: Int!
    var statusTimer: Timer?
    var turnTimer: Timer?
    var timeLeft: Int!
    var mode: Mode?
    var firstMyTurnAfterLoad = true
    
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
            playVC?.gameData = self.gameData
            playVC?.gameID = self.gameID
            playVC?.mode = self.mode
        } else if segue.identifier == "toEndGame" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.gameData.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        } else if segue.identifier == "toBasket" {
            let basketVC = segue.destination as? BasketVC
            basketVC?.gameData = gameData
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
        if isMyTurn { tryEndGame(title: "Закончить игру?", message: "") }
    }
    
    @IBAction func unwindFromBasketVC(_ unwindSegue: UIStoryboardSegue) {
        let _ = unwindSegue.source
        checkWordsCount()
    }
}

// MARK: - private functions
extension StartPairVC {
    var isMyTurn: Bool { //always true if offline game)
        return (mode == .offline) || (gameData.currentTeller.id == Auth().id)
    }
    var isTeller: Bool {
        return gameData.currentTeller.id == Auth().id
    }
    var isListener: Bool {
        return gameData.currentListener.id == Auth().id
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
    func showWarning(_ text: String) {
        self.title = text
    }
    
    var anotherPlayerIsGuessing: Bool {
        return turnTimer != nil
    }
    
    func reloadNames() {
        tellerNameLabel.text = gameData.currentTeller.name
        listenerNameLabel.text = gameData.currentListener.name
    }
    
    func prepareNewTurn(colorise: Bool = true) {
        reloadNames()
        checkWordsCount()
        helpMessage.isHidden = true
        
        if isMyTurn {
            if gameData.isOneFullCircle {
                if firstMyTurnAfterLoad { firstMyTurnAfterLoad = false } else { tryEndGame() }
            }
            circleView.isHidden = true
            timerLabel.isHidden = true
            goButton.enable()
        } else {
            createStatusTimer()
            goButton.disable()
            circleView.isHidden = false
            circleView.backgroundColor = K.Colors.foreground40
            timerLabel.isHidden = false
            timeLeft = gameData.settings.roundDuration
            timerLabel.text = String(timeLeft)
        }
        if colorise { coloriseBarView() }
    }
    func tryEndGame(title: String = "Вы закончили полный круг", message: String = "Все сыграли со всеми. Закончим игру?") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Давно пора", style: .destructive, handler: {
            action in self.showResults()
        }))
        alert.addAction(UIAlertAction(title: "Ещё поиграем", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateTitle() {
        if anotherPlayerIsGuessing {
            title = "Угадано: \(gameData.guessedThisTurn) слов"
        } else {
            checkWordsCount()
        }
    }
    func checkWordsCount() {
        title = "Осталось: \(gameData.leftWords.count) слов"
        if gameData.leftWords.count == 0 {
            showResults()
        }
    }
    func showResults() {
        performSegue(withIdentifier: "toEndGame", sender: self)
    }
}
