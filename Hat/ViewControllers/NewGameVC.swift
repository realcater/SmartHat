//
//  ViewController.swift
//  TrustOr
//
//  Created by Dmitry Dementyev on 13.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class NewGameVC: UIViewController {

    //var startVC : StartVC!
    var playersTVC: PlayersTVC!
    var game: Game!
    var playersNames = K.startPlayersNames
    var wordsQtyData = [5,30,40,50,60,70,80,90,100,110,120,130,140,150,160]
    var hardnessData : [Difficulty] = [.easy, .normal, .hard]
    var secQtyData = [10,20,30,40,50,60]
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var play: MyButton!
    @IBOutlet weak var add: MyButton!
    
    @IBAction func pressAdd(_ sender: Any) {
        playersTVC!.insertRow(playerName: "", at: playersNames.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K.Colors.background
        play.turnClickSoundOn(sound: K.Sounds.click)
        title = "Кто играет?"
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(0, inComponent: 0, animated: true)
        picker.selectRow(1, inComponent: 1, animated: true)
        picker.selectRow(0, inComponent: 2, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.foreground]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersList" {
            playersTVC = segue.destination as? PlayersTVC
            playersTVC?.playersNames = playersNames
        }
        if segue.identifier == "toStartPair" {
            let wordsQty = wordsQtyData[picker.selectedRow(inComponent: 0)]
            let difficulty = hardnessData[picker.selectedRow(inComponent: 1)]
            let time = secQtyData[picker.selectedRow(inComponent: 2)]

            game = Game(wordsQty: wordsQty, difficulty: difficulty, time: time, playersNames: playersNames)
            
            let startPairVC = segue.destination as? StartPairVC
            startPairVC?.game = self.game
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


