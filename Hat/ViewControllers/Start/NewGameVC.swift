//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

enum Mode {
    case offline
    case onlineNew
    case onlineJoin
}

class NewGameVC: UIViewController {
    var playersTVC: PlayersTVC!
    var gameData: GameData!
    var gameID: UUID?
    var playersList = PlayersList()
    var mode : Mode!
    var timer: Timer?
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var button: MyButton!
    
    @IBAction func pressButton(_ sender: Any) {
        if mode == .onlineNew {
            createOnlineGame()
        } else {
            performSegue(withIdentifier: "toStartPair", sender: self)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        showAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        button.turnClickSoundOn(sound: K.Sounds.click)
        if mode != .offline { replaceBackButton() }
        title = "Кто играет?"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        button.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
        preparePicker(setting: gameData?.settings ?? K.SettingsRow.start)
        if mode != .offline {
            button.disable()
        }
        if mode == .onlineJoin {
            picker.isUserInteractionEnabled = false
            createUpdateStatusTimer()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelTimer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            loadPlayersList()
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersList = playersList
            playersTVC.mode =  mode
            playersTVC?.delegate = self
        } else if segue.identifier == "toStartPair" {
                createGameData()
                let startPairVC = segue.destination as? StartPairVC
                startPairVC?.gameData = self.gameData
                playersList.saveToFile()
        } else if segue.identifier == "toInvitePlayer" {
            let invitePlayerVC = segue.destination as? InvitePlayerVC
            invitePlayerVC?.delegate = self
        }
    }
}

// MARK: - Private functions
private extension NewGameVC {
    func replaceBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "❌", style: .plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    func showAlert() {
        let alert = UIAlertController(title: "Вы точно хотите покинуть игру?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func preparePicker(setting: Settings) {
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(setting.wordsQtyRow, inComponent: 0, animated: true)
        picker.selectRow(setting.difficultyRow, inComponent: 1, animated: true)
        picker.selectRow(setting.roundDurationRow, inComponent: 2, animated: true)
    }
    func loadPlayersList() {
        switch mode {
        case .offline:
            playersList.loadFromFile()
        case .onlineNew:
            let me = Player(id: Auth().id, name: Auth().name!)
            playersList.players.append(me)
        default:
            playersList.players.append(contentsOf: gameData.players)
        }
    }
    func createGameData() {
        let settings = Settings(
            difficultyRow: picker.selectedRow(inComponent: 1),
            wordsQtyRow: picker.selectedRow(inComponent: 0),
            roundDurationRow: picker.selectedRow(inComponent: 2))
        gameData = GameData(settings: settings, players: playersList.players)
    }
    
    func createOnlineGame() {
        createGameData()
        button.disable()
        GameRequest.create(gameData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gameID):
                    self?.gameID = gameID
                    self?.changeModeToOnlineJoin()
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                    self?.button.enable()
                }
            }
        }
    }
    func changeModeToOnlineJoin() {
        setAcceptedStatuses()
        mode = .onlineJoin
        button.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
        title = "Ждём игроков..."
        playersTVC.playersList = playersList
        playersTVC.mode = mode
        picker.isUserInteractionEnabled = false
        playersTVC.tableView.reloadData()
        createUpdateStatusTimer()
    }
    func setAcceptedStatuses() {
        let myID = Auth().id
        playersList.players.forEach { $0.accepted = ($0.id == myID) }
    }
    func showWarning(_ text: String) {
        self.title = text
    }
    
    func update(from playersStatus: [PlayerStatus]) {
        var anythingChanged = false
        for playerStatus in playersStatus {
            let player = playersList.players.first { $0.id == playerStatus.playerID }
            if let player = player, player.accepted != playerStatus.accepted {
                player.accepted = playerStatus.accepted
                anythingChanged = true
            }
        }
        if anythingChanged {
            playersTVC?.playersList = playersList
            playersTVC?.tableView.reloadData()
            if everyPlayerReady {
                button.enable()
                title = "Все готовы!"
            }
        }
    }
    var everyPlayerReady: Bool {
        return !playersList.players.map{$0.accepted}.contains(false)
    }
    func updatePlayerStatus() {
        GameRequest.getPlayersStatus(gameID: self.gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let playersStatus):
                    self?.update(from: playersStatus)
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
}

// MARK: - Timer
extension NewGameVC {
    @objc func updateTimer() {
        updatePlayerStatus()
    }
    
    func createUpdateStatusTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: K.Server.Time.updatePlayersStatus, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
            timer?.fire()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
    
// MARK: - Delegates
extension NewGameVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return K.SettingsRow.wordsQty.count
        case 1: return K.SettingsRow.difficulty.count
        default: return K.SettingsRow.roundDuration.count
        }
    }
}
extension NewGameVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = K.Colors.foreground
        pickerLabel.textAlignment = NSTextAlignment.center
        
        pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        switch component {
        case 0: pickerLabel.text = String(K.SettingsRow.wordsQty[row])+" слов"
        case 1: pickerLabel.text = K.SettingsRow.difficulty[row].name()
        default: pickerLabel.text = String(K.SettingsRow.roundDuration[row])+" сек"
        }
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 1) {
            if (K.SettingsRow.difficulty[row] == .separator1) { button.disable() } else {
                if playersList.players.count >= K.minPlayersQty {
                    button.enable()
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let width = pickerView.frame.size.width
        switch component {
        case 0: return 0.27*width
        case 1: return 0.46*width
        default: return 0.27*width
        }
    }
}

protocol NewGameVCDelegate: class {
    func add(toGame player: Player) -> Bool
    func goToInvitePlayerVC()
    func disableButton()
}

extension NewGameVC: NewGameVCDelegate {
    func add(toGame player: Player) -> Bool {
        if playersList.players.contains(player) {
            return false
        } else {
            playersTVC.insertRow(player: player, at: playersList.players.count)
            if playersList.players.count == K.minPlayersQty {
                button.enable()
            }
            return true
        }
    }
    
    func goToInvitePlayerVC() {
        performSegue(withIdentifier: "toInvitePlayer", sender: self)
    }
    func disableButton() {
        button.disable()
    }
}
