import UIKit
import SwiftKeychainWrapper

class InvitePlayerVC: UIViewController {
    
    var player: Player!
    var playersList = PlayersList()
    weak var delegate: NewGameVCDelegate?
    
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var AddUserButton: MyButton!
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        if let player = player { delegate?.add(toGame: player) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap), singleTapCancelsTouchesInView: false)
        popupView.layer.cornerRadius = K.windowsCornerRadius
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
    }
    private func showWarning(_ text: String) {
        self.warningTextView.text = text
        self.warningTextView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInvitePlayerTVC" {
            loadPlayersList()
            let invitePlayerTVC = segue.destination as? InvitePlayerTVC
            invitePlayerTVC?.playersData = playersList
            invitePlayerTVC?.delegate = self
        }
    }
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadPlayersList() {
        let me = Player(id: Auth().id, name: Auth().name!)
        playersList.players.append(me)
        playersList.players.append(me)
        playersList.players.append(me)
        playersList.players.append(me)
    }
}

extension InvitePlayerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //name = textField.text!
    }
}

protocol InvitePlayerVCDelegate: class {
    func select(player: Player)
}

extension InvitePlayerVC: InvitePlayerVCDelegate {
    func select(player: Player) {
        self.player = player
        textField.text = player.name
    }
}
