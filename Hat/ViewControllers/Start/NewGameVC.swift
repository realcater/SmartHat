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
    var game: Game!
    var playersList = PlayersList()
    var wordsQtyData = [20,30,40,50,60,70,80,90,100,120,140,160,250,400,600]
    var hardnessData = GameDifficulty.allCases
    
    var secQtyData = [10,20,30,40,50,60]
    var mode : Mode!
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var play: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        play.turnClickSoundOn(sound: K.Sounds.click)
        title = "Кто играет?"
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(4, inComponent: 0, animated: true)
        picker.selectRow(2, inComponent: 1, animated: true)
        picker.selectRow(2, inComponent: 2, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        if mode != .offline {
            play.disable()
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
            let wordsQty = wordsQtyData[picker.selectedRow(inComponent: 0)]
            let difficulty = hardnessData[picker.selectedRow(inComponent: 1)]
            let roundDuration = secQtyData[picker.selectedRow(inComponent: 2)]
            let settings = GameSettings(difficulty: difficulty, wordsQty: wordsQty, roundDuration: roundDuration)
            game = Game(wordsQty: wordsQty, settings: settings, players: playersList.players)
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
            playersList.saveToFile()
        } else if segue.identifier == "toInvitePlayer" {
            let invitePlayerVC = segue.destination as? InvitePlayerVC
            invitePlayerVC?.delegate = self
        }
    }
}

extension NewGameVC {
    func loadPlayersList() {
        switch mode {
        case .offline:
            playersList.loadFromFile()
        case .onlineNew:
            let me = Player(id: Auth().id, name: Auth().name!)
            playersList.players.append(me)
        default:
            playersList.players.append(contentsOf: game.players)
        }
    }
}

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
            if (hardnessData[row] == .separator1) { play.disable() } else { play.enable() }
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
    func add(toGame player: Player)
    func goToInvitePlayerVC()
}

extension NewGameVC: NewGameVCDelegate {
    func add(toGame player: Player) {
        playersTVC.insertRow(player: player, at: playersList.players.count)
        print(playersList.players.map {$0.name})
        print(playersTVC.playersList.players.map {$0.name})
    }
    func goToInvitePlayerVC() {
        performSegue(withIdentifier: "toInvitePlayer", sender: self)
    }
}
