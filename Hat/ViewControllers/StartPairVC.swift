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
    
    @IBOutlet weak var listenerNameLabel: UILabel!
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        goButton.turnClickSoundOn(sound: K.Sounds.click)
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        game.startNewPair()
        tellerNameLabel.text = game.currentTeller.name
        listenerNameLabel.text = game.currentListener.name
        title = "Осталось: \(game.leftWords.count) слов"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay" {
            let playVC = segue.destination as? PlayVC
            playVC?.game = self.game
        }
    }
}

