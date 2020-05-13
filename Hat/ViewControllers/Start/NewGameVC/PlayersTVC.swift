import UIKit

class PlayersTVC: UITableViewController {
    @IBAction func pressAddPlayerButton(_ sender: Any) {
        if mode == .offline {
            insertRow(player: Player(name: ""), at: playersList.players.count)
        } else if mode == .onlineCreate {
            delegate?.goToInvitePlayerVC()
        }
    }
    
    var playersList: PlayersList!
    var rowEdit: Int?
    var mode : Mode!
    weak var delegate: NewGameVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditing = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersList.players.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Players", for: indexPath)
        let textField = cell.viewWithTag(1000) as! UITextField
        let addPlayerButton = cell.viewWithTag(1001) as! MyButton
        let statusImageView = cell.viewWithTag(1002) as! UIImageView
        if (indexPath.row == playersList.players.count) {
            textField.isHidden = true
            addPlayerButton.isHidden = (mode == .onlineWait) || (mode == .onlineReady)
            addPlayerButton.turnClickSoundOn(sound: K.Sounds.click)
        } else {
            textField.text = playersList.players[indexPath.row].name
            textField.isUserInteractionEnabled = (mode == .offline)
            addPlayerButton.isHidden = true
            if (mode == .onlineWait) || (mode == .onlineReady) {
                if playersList.players[indexPath.row].accepted {
                    let iconFileName = playersList.players[indexPath.row].inGame ? K.FileNames.onlineIcon : K.FileNames.offlineIcon
                    statusImageView.image = UIImage(named: iconFileName)
                } else {
                    statusImageView.image = UIImage(named: K.FileNames.waitIcon)
                    statusImageView.tintColor = K.Colors.foreground
                    statusImageView.rotate(duration: 4)
                }
            }
        }
        if (indexPath.row == playersList.players.count-1) && (textField.text!.count == 0) {
            textField.becomeFirstResponder()
        }
        textField.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ((indexPath.row == playersList.players.count) || (mode == .onlineWait) || (mode == .onlineReady)) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let isMe = playersList.players[indexPath.row].id == Auth().id
        switch (mode,isMe) {
        case (.onlineWait,_): return .none
        case (.onlineCreate,true): return .none
        case (.onlineCreate,false): return .delete
        default: return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if mode == .offline {
                guard playersList.players.count > K.minPlayersQty else { return }
            } else if playersList.players.count <= K.minPlayersQty {
                delegate?.disableButton()
            }
            playersList.players.remove(at: indexPath.row)
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
        return (mode == .onlineWait) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == playersList.players.count {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = playersList.players[sourceIndexPath.row]
        playersList.players.remove(at: sourceIndexPath.row)
        playersList.players.insert(itemToMove, at: destinationIndexPath.row)
    }
}
//MARK: - Public functions
extension PlayersTVC {
    func insertRow(player: Player, at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        playersList.players.insert(player, at: indexPath.row)
        tableView.endUpdates()
    }
}

extension PlayersTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rowEdit = (playersList.players.map {$0.name}).firstIndex{$0 == textField.text}
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let rowEdit = rowEdit {
            playersList.players[rowEdit].name = textField.text!
        }
    }
}
