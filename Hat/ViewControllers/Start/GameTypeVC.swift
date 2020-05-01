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
    @IBAction func onlineGameButtonPressed(_ sender: Any) {
        checkRegistration()
    }
    var notConfirmedName = ""
    var name: String? = nil
    
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
            let createJoinVC = segue.destination as? CreateJoinVC
            createJoinVC?.title = name
        } else if segue.identifier == "toRegistration" {
            let newUserVC = segue.destination as? NewUserVC
            newUserVC?.delegate = self
            newUserVC!.name = notConfirmedName
        }
    }
}

extension GameTypeVC {
    func checkRegistration() {
        guard let uuid = UIDevice.current.identifierForVendor else {
            fatalError("Can't get UIDevice")
        }
        title = "Подключаемся к серверу..."
        UserRequest(userID: uuid).searchByID(uuid) { [weak self] result in
            switch result {
            case .success(let user):
                self?.name = user.name
                DispatchQueue.main.async { [weak self] in
                    self?.title = "Как играем, \(self?.name ?? "")?"
                    self?.performSegue(withIdentifier: "online", sender: self)
                }
            case .noConnection:
                DispatchQueue.main.async { [weak self] in
                    self?.title = K.Server.Warnings.noConnection
                }
            case .failureOther:
                DispatchQueue.main.async { [weak self] in
                    self?.title = K.Server.Warnings.serverError
                }
            case .notFound:
                DispatchQueue.main.async { [weak self] in
                    self?.title = "Давайте знакомиться!"
                    self?.performSegue(withIdentifier: "toRegistration", sender: self)
                }
            }
        }
    }
}

protocol GameTypeVCDelegate: class {
    func successfullRegistration(name: String)
}

extension GameTypeVC: GameTypeVCDelegate {
    func successfullRegistration(name: String) {
        self.name = name
        title = "Добро пожаловать, \(name)!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.performSegue(withIdentifier: "online", sender: self)
        })
    }
}
