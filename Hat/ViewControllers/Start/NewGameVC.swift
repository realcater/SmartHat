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
    var game: GameData!
    var playersData = PlayersData()
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
        picker.selectRow(1, inComponent: 1, animated: true)
        picker.selectRow(2, inComponent: 2, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
        if mode != .offline {
            play.isEnabled = false
            play.backgroundColor = K.Colors.lightGray
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            playersData.load()
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersData = playersData
            playersTVC.mode = mode
            
        }
        if segue.identifier == "toStartPair" {
            let wordsQty = wordsQtyData[picker.selectedRow(inComponent: 0)]
            let gameDifficulty = hardnessData[picker.selectedRow(inComponent: 1)]
            let time = secQtyData[picker.selectedRow(inComponent: 2)]
            game = GameData(wordsQty: wordsQty, gameDifficulty: gameDifficulty, time: time, players: playersData.players)
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
            playersData.save()
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
        
        switch component {
        case 0:
            pickerLabel.text = String(wordsQtyData[row])+" слов"
            pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        case 1:
            pickerLabel.text = K.gameDiffNames[hardnessData[row]]!
            pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        default:
            pickerLabel.text = String(secQtyData[row])+" сек"
            pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 1) {
            play.isEnabled = (hardnessData[row] == .separator1) ? false : true
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
