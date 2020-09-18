import UIKit

class PlayersTVC: UITableViewController {
    @IBAction func pressAddPlayerOnlineButton(_ sender: Any) {
        delegate?.goToInvitePlayerVC(isOnlinePlayerToInvite: true)
    }
    
    @IBAction func pressAddPlayerOfflineButton(_ sender: Any) {
        switch mode {
        case .offline:
            insertRow(player: Player(name: ""), at: playersList.players.count)
        default:
            delegate?.goToInvitePlayerVC(isOnlinePlayerToInvite: false)
            
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
        let addPlayerOnlineButton = cell.viewWithTag(1001) as! MyButton
        let addPlayerOffineButton = cell.viewWithTag(1003) as! MyButton
        let statusImageView = cell.viewWithTag(1002) as! UIImageView
        if indexPath.row == playersList.players.count {
            textField.isHidden = true
            statusImageView.isHidden = true
            setButtons(contentView: cell.viewWithTag(1004)!, onlineBtn: addPlayerOnlineButton, offlineBtn: addPlayerOffineButton)
        } else {
            textField.isHidden = false
            textField.text = playersList.players[indexPath.row].name
            textField.isUserInteractionEnabled = (mode == .offline)
            addPlayerOnlineButton.isHidden = true
            addPlayerOffineButton.isHidden = true
            statusImageView.isHidden = false
            if (mode != .offline) && (mode != .onlineCreateBefore) {
                if playersList.players[indexPath.row].accepted {
                    if playersList.players[indexPath.row].id == Auth().id {
                        statusImageView.tintColor = K.Colors.foreground
                        statusImageView.image = UIImage(named: K.FileNames.iPhoneIcon)
                    } else {
                        let iconFileName = playersList.players[indexPath.row].inGame ? K.FileNames.onlineIcon : K.FileNames.offlineIcon
                        statusImageView.image = UIImage(named: iconFileName)
                    }
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
        return ((indexPath.row == playersList.players.count) || (mode == .onlineJoin)) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let isMe = (playersList.players[indexPath.row].id == Auth().id) && (playersList.players[indexPath.row].name == Auth().name)
        switch (mode,isMe) {
        case (.onlineJoin,_): return .none
        case (.onlineCreateBefore,true): return .none
        case (.onlineCreateAfter,true): return .none
        default: return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            deletePlayer(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return (mode == .onlineJoin) ? false : true
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
        if mode != .offline { delegate?.updatePlayersList(players: playersList.players) }
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
    
    func deletePlayer(at indexPath: IndexPath) {
        let row = indexPath.row
        if mode == .offline {
            guard playersList.players.count > K.minPlayersQty else { return }
        }
        playersList.players.remove(at: row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        if let rowEdit = rowEdit, row < rowEdit { self.rowEdit!-=1 }
        if mode == .onlineCreateAfter {
            delegate?.updatePlayersList(players: playersList.players)
            if playersList.players.count <= K.minPlayersQty {
                delegate?.disableButton()
            }
        }
    }
    func setButtons(contentView: UIView, onlineBtn: MyButton, offlineBtn: MyButton) {
        onlineBtn.makeRounded(sound: K.sounds.click)
        offlineBtn.makeRounded(sound: K.sounds.click)
        switch mode {
        case .onlineCreateBefore:
            onlineBtn.isHidden = true
            offlineBtn.isHidden = true
        case .onlineCreateAfter:
            onlineBtn.isHidden = false
            offlineBtn.isHidden = false
            contentView.getConstraint(named: "OnlineBtnOffset")?.constant = -50
            contentView.getConstraint(named: "OfflineBtnOffset")?.constant = 50
        default:
            onlineBtn.isHidden = true
            offlineBtn.isHidden = false
            contentView.getConstraint(named: "OfflineBtnOffset")?.constant = 0
        }
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
