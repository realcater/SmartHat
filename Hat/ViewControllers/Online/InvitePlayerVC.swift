import UIKit
import SwiftKeychainWrapper

class InvitePlayerVC: UIViewController {
    var _player: Player?
    var selectedPlayer: Player? {
        set {
            switch (_player != nil, newValue != nil) {
            case (false, true):
                addPlayerButton.enable()
            case (true, false):
                addPlayerButton.disable()
            default: break
            }
            _player = newValue
        }
        get {
            return _player
        }
    }
    var playersList = PlayersList()
    weak var delegate: NewGameVCDelegate?
    var invitePlayerTVC: InvitePlayerTVC?
    
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addPlayerButton: MyButton!
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        if let player = selectedPlayer {
            delegate?.add(toGame: player)
            dismiss(animated: true, completion: nil)
        } else {
            self.showWarning("Игрок не найден")
            textField.becomeFirstResponder()
        }
        
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        hideWarning()
        guard textField.text!.count > 0 else {
            self.playersList.players = []
            self.selectedPlayer = nil
            invitePlayerTVC?.tableView.reloadData()
            return
        }
        let searchRequestData = SearchRequestData(text: textField.text!, maxResultsQty: 10)
        UserRequest.search(with: searchRequestData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let users):
                    var textIsInTheList = false
                    self?.playersList.players = users.map {
                        if $0.name == textField.text {
                            self?.selectedPlayer = $0.makePlayer()
                            textIsInTheList = true
                        }
                        return $0.makePlayer()
                    }
                    if !textIsInTheList { self?.selectedPlayer = nil }
                    self?.invitePlayerTVC?.tableView.reloadData()
                    if users.count == 0 { self?.selectedPlayer = nil }
                case .failure(let error):
                    self?.playersList.players = []
                    self?.selectedPlayer = nil
                    self?.invitePlayerTVC?.tableView.reloadData()
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap), singleTapCancelsTouchesInView: false)
        popupView.layer.cornerRadius = K.windowsCornerRadius
        addPlayerButton.disable()
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
    }
    private func showWarning(_ text: String) {
        self.warningTextView.text = text
        self.warningTextView.isHidden = false
    }
    private func hideWarning() {
        self.warningTextView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInvitePlayerTVC" {
            self.invitePlayerTVC = segue.destination as? InvitePlayerTVC
            self.invitePlayerTVC?.playersList = self.playersList
            self.invitePlayerTVC?.delegate = self
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
        self.selectedPlayer = player
        textField.text = player.name
        textField.becomeFirstResponder()
        textFieldDidChange(textField)
    }
}
