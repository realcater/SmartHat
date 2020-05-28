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
    //var notConfirmedName = ""
    var name: String? = nil
    var tryConnectOnlineGame = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        offlineGameButton.turnClickSoundOn(sound: K.sounds.click)
        onlineGameButton.turnClickSoundOn(sound: K.sounds.click)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        if let name = Auth().name {
            title = "Как играем, \(name)?"
        } else {
            title = "Как играем?"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offline" {
            let newGameVC = segue.destination as? NewGameVC
            newGameVC?.mode = .offline
            tryConnectOnlineGame = false
            self.title = ""
        } else if segue.identifier == "online" {
            let createJoinVC = segue.destination as? CreateJoinVC
            createJoinVC?.title = name
            self.title = ""
        } else if segue.identifier == "toRegistration" {
            let newUserVC = segue.destination as? NewUserVC
            newUserVC?.delegate = self
            //newUserVC!.name = notConfirmedName
        }
    }
}

extension GameTypeVC {
    func checkRegistration() {
        guard let uuid = UIDevice.current.identifierForVendor else {
            fatalError("Can't get UIDevice")
        }
        tryConnectOnlineGame = true
        title = "Подключаемся к серверу..."
        tryGetUser(by: uuid) {
            self.title = "Как играем, \(self.name ?? "")?"
            self.loadSettings() {
                DispatchQueue.main.async { [weak self] in
                    guard K.Server.currentAppVersion >= K.Server.settings.minimumAppVersion else {
                        self?.showAlert()
                        self?.showWarning("Обновите приложение")
                        return
                    }
                    self?.performSegue(withIdentifier: "online", sender: self)
                }
            }
        }
    }
    func tryGetUser(by uuid: UUID, completion: @escaping () -> Void) {
        UserRequest.get(userID: uuid) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let user):
                    self?.name = user.name
                    completion()
                case .failure(let error):
                    switch error {
                    case .notFound:
                        self?.title = "Давайте знакомиться!"
                        self?.performSegue(withIdentifier: "toRegistration", sender: self)
                    default:
                        self?.title = K.Server.warnings[error]
                        if error == .noConnection && (self?.tryConnectOnlineGame ?? false) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + K.Server.settings.updateFullTillNextTry) {
                                self?.tryGetUser(by: uuid) {
                                    self?.title = "Сервер доступен"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func loadSettings(completion: @escaping () -> Void) {
        UserRequest.loadSettings() { [weak self] result in
            switch result {
            case .success(let clientSettings):
                K.Server.settings = clientSettings
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showWarningOrTitle(error)
                }
            }
            completion()
        }
    }
    func showAlert() {
        let alert = UIAlertController(title: "Обновите приложение", message: "Для онлайн-игры требуется более новая версия программы", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
