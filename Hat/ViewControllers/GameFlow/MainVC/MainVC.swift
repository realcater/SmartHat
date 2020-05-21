//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
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
    var turnTimer: Timer?
    var statusTimer: Timer?
    var timeLeft: Int!
    var mode: Mode?
    var firstTurnAfterLoad = true
    var currentTitle: String?
    var requestIsBeingHandled = false
    var update: Update!
    var shouldUpdateGameAtTheEnd = true
    var explainVC: ExplainVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        circleView.layer.cornerRadius = K.CircleCornerRadius.small
        print("StartPairVC.game=\(Unmanaged.passUnretained(game).toOpaque())")
        if mode != .offline {
            update = Update(game: game, delegate: self, showWarningOrTitle: self.showWarningOrTitle)
        }
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
        if segue.identifier == "toExplain" {
            explainVC = segue.destination as? ExplainVC
            explainVC?.game = self.game
            explainVC?.mode = self.mode
            explainVC?.update = update
            update?.stopGetFrequent()
        } else if segue.identifier == "toEndGame" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.data.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
            endGameVC?.game = game
            if shouldUpdateGameAtTheEnd { endGameVC?.update = update }
            update?.stopGetFrequent()
            statusTimer?.invalidate()
        } else if segue.identifier == "toBasket" {
            let basketVC = segue.destination as? BasketVC
            basketVC?.game = game
            basketVC?.editable = game.userOwnerID == Auth().id
            basketVC?.update = update
        }
    }
}

// MARK: - buttons handlers
extension MainVC {
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
extension MainVC {
    
    var isMyPreviousTurn: Bool {  //always false if offline game)
        return (mode != .offline) && (game.prevTeller?.id == Auth().id)
    }
    var isTeller: Bool {
        return game.currentTeller?.id == Auth().id
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
        tellerNameLabel.text = game.currentTeller?.name
        listenerNameLabel.text = game.currentListener.name
    }
    
    func prepareNewTurn(colorise: Bool = true) {
        print("=========prepareNewTurn: \(game.turn)=============")
        if colorise { coloriseBarView() }
        reloadNames()
        helpMessage.isHidden = true
        
        update?.startGetFrequent(every: K.Server.Time.updateGameData)
        
        if isMyTurn {
            print("====MY TURN====")
            circleView.isHidden = true
            timerLabel.isHidden = true
            goButton.enable()
        } else {
            print("====NOT MY TURN====")
            goButton.disable()
            circleView.isHidden = false
            circleView.backgroundColor = K.Colors.foreground40
            timerLabel.isHidden = false
            timeLeft = game.data.settings.roundDuration
            timerLabel.text = String(timeLeft)
        }
        
        if game.guessedThisTurn != 0 {
            print("guessedThisTurn=\(game.guessedThisTurn). Reset to 0")
            game.guessedThisTurn = 0
            
        }
        checkWordsCount()
        if isMyPreviousTurn { update.setFull() }
        if !firstTurnAfterLoad && self.isMyTurn && self.game.isOneFullCircle {
            tryEndGame(title: "Вы закончили полный круг", message: "Все сыграли со всеми. Закончим игру?")
        }
        firstTurnAfterLoad = false
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
        currentTitle = "Осталось: \(game.data.leftWords.count-game.guessedThisTurn) слов"
        if title != currentTitle { title = currentTitle }
        if game.data.leftWords.count == 0 {
            showResults()
        }
    }
    func showResults() {
        update?.stopGetFrequent()
        performSegue(withIdentifier: "toEndGame", sender: self)
    }
}
