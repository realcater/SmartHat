//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController {

    var startVC : StartVC!
    var playersTVC: PlayersTVC!
    var game: Game!
    var players: [Player] = K.startPlayers
    
    @IBOutlet weak var play: MyButton!
    @IBOutlet weak var add: MyButton!
    
    @IBAction func pressAdd(_ sender: Any) {
        let emptyPlayer = Player(name: "")
        playersTVC!.insertRow(player: emptyPlayer, at: players.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        play.makeRounded(color: K.Colors.foreground, textColor: K.Colors.background, sound: K.Sounds.click)
        //view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.players = players
        }
        if segue.identifier == "toStartPair" {
            game = Game(wordsQty: 60, difficulty: Difficulty.hard, time: 30, players: players)
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
        }
        
    }
}
