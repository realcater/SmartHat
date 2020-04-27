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
        insertRow(playerName: "", at: playersNames.count)
    }
    
    var playersNames: NSMutableArray!
    var rowEdit: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersNames.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayersListItem", for: indexPath)
        let textField = cell.viewWithTag(1000) as! UITextField
        let addPlayerButton = cell.viewWithTag(1001) as! MyButton
        if (indexPath.row == playersNames.count) {
            textField.isHidden = true
            addPlayerButton.isHidden = false
            addPlayerButton.turnClickSoundOn(sound: K.Sounds.click)
        } else {
            textField.text = playersNames[indexPath.row] as? String
            addPlayerButton.isHidden = true
            
        }
        textField.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == playersNames.count) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            playersNames.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        let itemToMove = playersNames[sourceIndexPath.row]
        playersNames.removeObject(at: sourceIndexPath.row)
        playersNames.insert(itemToMove, at: destinationIndexPath.row)
    }
}
//MARK: - Public functions
extension PlayersTVC {
    func deleteRow(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        playersNames.removeObject(at: row)
        tableView.endUpdates()
    }
    
    func moveRow(at: Int, to: Int) {
        let indexPathAt = IndexPath(row: at, section: 0)
        let indexPathTo = IndexPath(row: to, section: 0)
        //tableView.beginUpdates()
        UIView.animate(withDuration: K.Delays.moveOneRow, animations: {
            self.tableView.moveRow(at: indexPathAt, to: indexPathTo)
        })
        let itemToMove = playersNames[at]
        playersNames.removeObject(at: at)
        playersNames.insert(itemToMove, at: to)
    }
    
    func insertRow(playerName: String, at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        playersNames.insert(playerName, at: indexPath.row)
        tableView.endUpdates()
    }
    
    func show() {
        tableView.isHidden = false
    }
    func hide() {
        tableView.isHidden = true
    }
}

extension PlayersTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rowEdit = (playersNames as! [String]).index{$0 == textField.text}
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let rowEdit = rowEdit {
            playersNames[rowEdit] = textField.text!
        }
    }
}
