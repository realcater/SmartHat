//
//  WordsTVC.swift
//  Spynames
//
//  Created by Dmitry Dementyev on 20/01/2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class PlayersTVC: UITableViewController {
    @IBAction func pressAddPlayerButton(_ sender: Any) {
        insertRow(player: Player(name: ""), at: playersData.players.count)
    }
    
    var playersData: PlayersData!
    var rowEdit: Int?
    var mode : Mode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersData.players.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayersListItem", for: indexPath)
        let textField = cell.viewWithTag(1000) as! UITextField
        let addPlayerButton = cell.viewWithTag(1001) as! MyButton
        let statusImageView = cell.viewWithTag(1002) as! UIImageView
        if (indexPath.row == playersData.players.count) {
            textField.isHidden = true
            addPlayerButton.isHidden = false
            addPlayerButton.turnClickSoundOn(sound: K.Sounds.click)
        } else {
            textField.text = playersData.players[indexPath.row].name
            addPlayerButton.isHidden = true
            if mode != .offline {
                statusImageView.image = UIImage(named: K.FileNames.waitIcon)
                statusImageView.rotate(duration: 4)
            }
        }
        if (indexPath.row == playersData.players.count-1) && (textField.text!.count == 0) {
            textField.becomeFirstResponder()
        }
        textField.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == playersData.players.count) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard playersData.players.count > K.minPlayersQty else { return }
            playersData.players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let rowEdit = rowEdit, indexPath.row < rowEdit { self.rowEdit!-=1 }
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = playersData.players[sourceIndexPath.row]
        playersData.players.remove(at: sourceIndexPath.row)
        playersData.players.insert(itemToMove, at: destinationIndexPath.row)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cool!")
    }
}
//MARK: - Public functions
extension PlayersTVC {
    func insertRow(player: Player, at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        playersData.players.insert(player, at: indexPath.row)
        tableView.endUpdates()
    }
}

extension PlayersTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rowEdit = (playersData.players.map {$0.name}).firstIndex{$0 == textField.text}
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let rowEdit = rowEdit {
            playersData.players[rowEdit].name = textField.text!
        }
    }
}
