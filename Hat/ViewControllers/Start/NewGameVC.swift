//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController {

    var playersTVC: PlayersTVC!
    var game: GameData!
    var players: [Player] = []
    var wordsQtyData = [20,30,40,50,60,70,80,90,100,120,140,160,250,400,600]
    var hardnessData : [Difficulty] = [.easy, .normal, .hard]
    var secQtyData = [10,20,30,40,50,60]
    var isOnlineGame : Bool!
    
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
        picker.selectRow(1, inComponent: 1, animated: true)
        picker.selectRow(2, inComponent: 2, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        if isOnlineGame {
            play.isEnabled = false
            play.backgroundColor = K.Colors.lightGray
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            players = load()
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersNames = NSMutableArray(array: players.map { $0.name })
            playersTVC.isOnlineGame = isOnlineGame
            
        }
        if segue.identifier == "toStartPair" {
            let wordsQty = wordsQtyData[picker.selectedRow(inComponent: 0)]
            let difficulty = hardnessData[picker.selectedRow(inComponent: 1)]
            let time = secQtyData[picker.selectedRow(inComponent: 2)]
            if !isOnlineGame {
                players = playersTVC.playersNames.map { Player(name: $0 as! String) }
            }
            game = GameData(wordsQty: wordsQty, difficulty: difficulty, time: time, players: players)
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
            save(players: players)
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
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0: return NSAttributedString(string: String(wordsQtyData[row])+" слов", attributes: [NSAttributedString.Key.foregroundColor : K.Colors.foreground])
        case 1: return NSAttributedString(string: K.diffNames[hardnessData[row]]!, attributes: [NSAttributedString.Key.foregroundColor : K.Colors.foreground])
        default: return NSAttributedString(string: String(secQtyData[row])+" сек", attributes: [NSAttributedString.Key.foregroundColor : K.Colors.foreground])
        }
    }
    
}
    // MARK: - Save/Load Players
extension NewGameVC {
    func save(players: [Player]) {
        let encodedData = try! JSONEncoder().encode(players)
        NSKeyedArchiver.archiveRootObject(encodedData, toFile: plistFileName)
    }
        
    func load() -> [Player] {
        if let encodedData = NSKeyedUnarchiver.unarchiveObject(withFile: plistFileName) as? Data, let players = try? JSONDecoder().decode([Player].self, from: encodedData) {
                return  players
        }
        return K.startPlayers
    }
    
    var plistFileName : String {
        let fileName = isOnlineGame ? "online" : "offline"
        return Helper.plistFileName(fileName)
    }
}


