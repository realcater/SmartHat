//
//  WordsTVC.swift
//  Spynames
//
//  Created by Dmitry Dementyev on 20/01/2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class PlayersTVC: UITableViewController {//}, UITextFieldDelegate {
    
    var players: [Player]!
    var rowEdit: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = true
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayersListItem", for: indexPath)
        let textField = cell.viewWithTag(1000) as! UITextField
        let player = players[indexPath.row]
        textField.text = player.name
        textField.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    /*
     override func tableView(_ tableView: UITableView,
     editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
     return UITableViewCell.EditingStyle.delete
     }
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            for player in players { print(player.name) }
            print("===")
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
        let itemToMove = players[sourceIndexPath.row]
        players.remove(at: sourceIndexPath.row)
        players.insert(itemToMove, at: destinationIndexPath.row)
    }
}
//MARK: - Public functions
extension PlayersTVC {
    func deleteRow(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        players.remove(at: row)
        tableView.endUpdates()
    }
    
    func moveRow(at: Int, to: Int) {
        let indexPathAt = IndexPath(row: at, section: 0)
        let indexPathTo = IndexPath(row: to, section: 0)
        //tableView.beginUpdates()
        UIView.animate(withDuration: K.Delays.moveOneRow, animations: {
            self.tableView.moveRow(at: indexPathAt, to: indexPathTo)
        })
        let itemToMove = players[at]
        players.remove(at: at)
        players.insert(itemToMove, at: to)
    }
    func deleteAll() {
        players.removeAll()
        tableView.reloadData()
    }
    func insertRow(player: Player, at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        players.insert(player, at: indexPath.row)
        tableView.endUpdates()
    }
    /*
     func deletePlayer(player: Player) {
     let row = players.index{$0 === player}
     if let row = row { deleteRow(at: row) }
     }*/
    func show() {
        tableView.isHidden = false
    }
    func hide() {
        tableView.isHidden = true
    }
}

extension PlayersTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let rowEdit = rowEdit {
            players[rowEdit].name = textField.text!
        }
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rowEdit = players.index{$0.name == textField.text}
    }
}
