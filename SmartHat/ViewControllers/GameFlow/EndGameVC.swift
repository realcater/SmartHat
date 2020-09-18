//
//  ResultsVC.swift
//  Hat
//
//  Created by Dmitry Dementyev on 27.12.2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class EndGameVC: UIViewController {

    @IBOutlet weak var ggButton: MyButton!
    
    var players: [Player]!
    var game: Game!
    var update: Update?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ggButton.makeRounded(color: K.Colors.foreground)
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        K.sounds.applause?.play()
        title = "Результаты"
        game.turn = K.endTurnNumber
        update?.setFull()
         
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultsList" {
            let endGameTVC = segue.destination as? EndGameTVC
            endGameTVC?.players = players
        }
    }
}
