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
    var playersNames = K.startPlayersNames
    
    @IBOutlet weak var play: MyButton!
    @IBOutlet weak var add: MyButton!
    
    @IBAction func pressAdd(_ sender: Any) {
        playersTVC!.insertRow(playerName: "", at: playersNames.count)
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
            playersTVC?.playersNames = playersNames
        }
        if segue.identifier == "toStartPair" {
            game = Game(wordsQty: 60, difficulty: Difficulty.hard, time: 30, playersNames: playersNames)
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
            print(playersNames)
        }
        
    }
}

