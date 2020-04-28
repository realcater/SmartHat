//
//  StartViewController.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 27.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class GameTypeVC: UIViewController {

    @IBOutlet weak var offlineGameButton: MyButton!
    @IBOutlet weak var onlineGameButton: MyButton!
    var notConfirmedName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        offlineGameButton.turnClickSoundOn(sound: K.Sounds.click)
        onlineGameButton.turnClickSoundOn(sound: K.Sounds.click)
        title = "Как играем?"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offline" {
            let newGameVC = segue.destination as? NewGameVC
            newGameVC?.isOnlineGame = false
        } else if segue.identifier == "online" {
            let isRegistered = loadRegistration()
            if !isRegistered {
                performSegue(withIdentifier: "toRegistration", sender: self)
            }
        } else if segue.identifier == "toRegistration" {
            let newUserVC = segue.destination as? NewUserVC
            newUserVC?.delegate = self
            newUserVC!.name = notConfirmedName
        }
    }
}

extension GameTypeVC {
    func loadRegistration() -> Bool {
        let fileName = Helper.plistFileName("isRegistered")
        if let encodedData = NSKeyedUnarchiver.unarchiveObject(withFile: fileName) as? Data, let isRegistered = try? JSONDecoder().decode(Bool.self, from: encodedData) {
                return isRegistered
        }
        return false
    }
}

protocol GameTypeVCDelegate: class {
    func setNotConfirmedName(name: String)
}

extension GameTypeVC: GameTypeVCDelegate {
    func setNotConfirmedName(name: String) {
        notConfirmedName = name
    }
}
