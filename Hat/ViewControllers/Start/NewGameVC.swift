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
    var wordsQtyData = [20,30,40,50,60,70,80,90,100,120,140,160,250,400,600]
    var hardnessData = GameDifficulty.allCases
    
    var secQtyData = [10,20,30,40,50,60]
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        button.turnClickSoundOn(sound: K.Sounds.click)
        title = "Кто играет?"
        preparePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        button.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
        if mode != .offline {
            button.disable()
        }
        if mode == .onlineJoin {
            picker.isUserInteractionEnabled = false
        }
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
    func preparePicker() {
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(4, inComponent: 0, animated: true)
        picker.selectRow(2, inComponent: 1, animated: true)
        picker.selectRow(2, inComponent: 2, animated: true)
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
        let wordsQty = wordsQtyData[picker.selectedRow(inComponent: 0)]
        let difficulty = hardnessData[picker.selectedRow(inComponent: 1)]
        let roundDuration = secQtyData[picker.selectedRow(inComponent: 2)]
        let settings = GameSettings(difficulty: difficulty, wordsQty: wordsQty, roundDuration: roundDuration)
        gameData = GameData(wordsQty: wordsQty, settings: settings, players: playersList.players)
        playersList.accepted = playersList.accepted.map { _ in false }
        print(playersList.accepted)
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
        setMeAcceptedGame()
        mode = .onlineJoin
        button.setTitle(K.Buttons.newGameVCTitle[mode], for: .normal)
        title = "Ждём игроков..."
        playersTVC.playersList = playersList
        playersTVC.mode = mode
        picker.isUserInteractionEnabled = false
        playersTVC.tableView.reloadData()
        createTimer()
    }
    func setMeAcceptedGame() {
        let myID = Auth().id
        playersList.accepted = playersList.players.map {
            return $0.id == myID ? true : false }
    }
    func showWarning(_ text: String) {
        self.title = text
    }
    func startListenToChangeAcceptedStatus() {
        //let timer =
    }
    
    func updatePlayersStatus(_ playersStatus: [PlayerStatus]) {
        var anythingChanged = false
        for playerStatus in playersStatus {
            let index = playersList.players.firstIndex { $0.id == playerStatus.playerID }
            if let index = index, playersList.accepted[index] != playerStatus.accepted {
                playersList.accepted[index] = playerStatus.accepted
                anythingChanged = true
            }
        }
        if anythingChanged {
            playersTVC?.playersList = playersList
            playersTVC?.tableView.reloadData()
            print("changed")
            if everyPlayerReady {
                
                button.enable()
                title = "Все готовы!"
                print("ready")
            }
        }
    }
    var everyPlayerReady: Bool {
        return !playersList.accepted.contains(false)
    }
}

// MARK: - Timer
extension NewGameVC {
    @objc func updateTimer() {
        GameRequest.getPlayersStatus(gameID: self.gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                print("update")
                switch result {
                case .success(let playersStatus):
                    self?.updatePlayersStatus(playersStatus)
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
    
    func createTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            timer?.tolerance = 0.1
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
        case 0: return wordsQtyData.count
        case 1: return hardnessData.count
        default: return secQtyData.count
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
        case 0: pickerLabel.text = String(wordsQtyData[row])+" слов"
        case 1: pickerLabel.text = K.gameDiffNames[hardnessData[row]]!
        default: pickerLabel.text = String(secQtyData[row])+" сек"
        }
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 1) {
            if (hardnessData[row] == .separator1) { button.disable() } else { button.enable() }
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
