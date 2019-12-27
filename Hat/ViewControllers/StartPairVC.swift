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
    
    
    @IBAction func pressEndButton(_ sender: Any) {
        tryEndGame(title: "Закончить игру?", message: "")
        print("press")
    }
    
    private func tryEndGame(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Давно пора", style: .destructive, handler: {
            action in self.showResults()
        }))
        alert.addAction(UIAlertAction(title: "Ещё поиграем", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    private func showResults() {
        performSegue(withIdentifier: "toEndGame", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        goButton.turnClickSoundOn(sound: K.Sounds.click)
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        game.startNewPair()
        tellerNameLabel.text = game.currentTeller.name
        listenerNameLabel.text = game.currentListener.name
        title = "Осталось: \(game.leftWords.count) слов"
        
        if game.isOneFullCircle() {
            tryEndGame(title: "Закончим игру?", message: "Вы закончили полный круг: все сыграли со всеми")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlay" {
            let playVC = segue.destination as? PlayVC
            playVC?.game = self.game
        } else if segue.identifier == "toEndGame" {
            let endGameVC = segue.destination as? EndGameVC
            endGameVC?.players = self.game.players.sorted { $0.ttlGuesses > $1.ttlGuesses }
        }
    }
}

