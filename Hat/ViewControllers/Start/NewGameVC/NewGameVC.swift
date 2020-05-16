//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

enum Mode {
    case offline
    case onlineCreate
    case onlineWait
    case onlineReady
}

class NewGameVC: UIViewController {
    var playersTVC: PlayersTVC!
    var gameData: GameData!
    var gameID: UUID?
    var playersList = PlayersList()
    var _mode : Mode!
    var statusTimer: Timer?
    
    var mode: Mode {
        get {
            return _mode
        }
        set {
            _mode = newValue
            if let gameData = gameData, gameData.turn == K.endTurnNumber {
                title = "Игра завершена"
                button?.enable()
                button?.setTitle("Смотреть результаты", for: .normal)
                return
            }
            title = K.Titles.newGame[mode]
            button?.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
            if mode == .onlineWait {
                button?.disable()
                if isViewLoaded { replaceBackButton() }
            } else {
                button?.enable()
            }
        }
    }
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var button: MyButton!
    
    @IBAction func pressButton(_ sender: Any) {
        if mode == .onlineCreate {
            createOnlineGame()
        } else {
            guard gameData.turn != K.endTurnNumber else {
                performSegue(withIdentifier: "directToEndGame", sender: self)
                return
            }
            performSegue(withIdentifier: "toStartPair", sender: self)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        showAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        button.turnClickSoundOn(sound: K.Sounds.click)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        preparePicker(setting: gameData?.settings ?? K.SettingsRow.start)
        mode = _mode
        if (mode == .onlineWait) || (mode == .onlineReady) {
            picker.isUserInteractionEnabled = false
            createStatusTimer()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            cancelStatusTimer()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            loadPlayersList()
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersList = playersList
            playersTVC.mode =  mode
            playersTVC?.delegate = self
        } else if segue.identifier == "toStartPair" {
            if mode == .offline {
                createGameData()
                playersList.saveToFile()
            }
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.gameData = self.gameData
            startPairVC?.mode = mode
            startPairVC?.gameID = gameID
            startPairVC?.statusTimer = statusTimer
        } else if segue.identifier == "directToEndGame" {
            cancelStatusTimer()
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.gameData.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        } else if segue.identifier == "toInvitePlayer" {
            let invitePlayerVC = segue.destination as? InvitePlayerVC
            invitePlayerVC?.delegate = self
        }
    }
}






