//
//  QuestionsView.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 14.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class PlayVC: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var guessed: MyButton!
    @IBOutlet weak var notGuessed: MyButton!
    
    @IBAction func guessedPressed(_ sender: Any) {
    }
    @IBAction func notGuessedPressed(_ sender: Any) {
    }
    var game = Game()
    
    private func prepareButtons() {
        guessed.makeRounded(color: K.Colors.foreground, textColor: K.Colors.background, sound: K.Sounds.click)
        notGuessed.makeRounded(color: UIColor.red, textColor: K.Colors.background, sound: K.Sounds.click)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        prepareButtons()
        title = "Играем!"
        for _ in Range(0...36) {
            game.startRound()
        }
    }

    // MARK: - Navigation
    
}
