//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit


class NewGameVC: UIViewController {
    var playersTVC: PlayersTVC!
    var game: Game!
    var playersList = PlayersList()
    var _mode : Mode!
    var statusTimer: Timer?
    var update: Update!
    
    @IBOutlet weak var onlineInfo: UITextView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var button: MyButton!
    
    var onlineInfoIsVisible = false {
        didSet {
            onlineInfo?.getConstraint(named: "onlineInfoHeight")?.constant =
                onlineInfoIsVisible ? 68 : 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        button.turnClickSoundOn(sound: K.sounds.click)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        preparePicker()
        mode = _mode
        if (mode == .onlineJoin) || (mode == .onlineCreateAfter) {
            picker.isUserInteractionEnabled = false
            createStatusTimer()
        }
        onlineInfoIsVisible = (mode == .onlineCreateAfter)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelStatusTimer()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            loadPlayersList()
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersList = playersList
            playersTVC.mode =  mode
            playersTVC?.delegate = self
        } else if segue.identifier == "toMain" {
            let mainVC = segue.destination as? MainVC
            mainVC?.game = self.game
            mainVC?.mode = mode
            if mode == .offline { return }
            if update == nil {
                update = Update(game: game, showWarningOrTitle: showWarningOrTitle)
            }
            mainVC?.update = update
        } else if segue.identifier == "directToEndGame" {
            cancelStatusTimer()
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.game = self.game
            endGameVC?.players = self.game.data.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        } else if segue.identifier == "toInvitePlayer" {
            let invitePlayerVC = segue.destination as? InvitePlayerVC
            invitePlayerVC?.delegate = self
        } else if segue.identifier == "toGameType" {
            self.title = ""
        }
    }
    
    @IBAction func pressButton(_ sender: Any) {
        switch mode {
        case .onlineCreateBefore:
            createOnlineGame()
        case .offline:
            createOfflineGame()
            performSegue(withIdentifier: "toMain", sender: self)
        default:
            if game?.turn == K.endTurnNumber {
                performSegue(withIdentifier: "directToEndGame", sender: self)
            } else {
                if game?.turn == -1 {
                    setGameStarted() {
                        self.performSegue(withIdentifier: "toMain", sender: self)
                    }
                }
            }
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        showAlert()
    }
}






