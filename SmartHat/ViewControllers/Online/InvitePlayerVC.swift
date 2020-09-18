import UIKit
import SwiftKeychainWrapper

class InvitePlayerVC: UIViewController {
    weak var delegate: NewGameVCDelegate?
    var _player: Player?
    var playersList = PlayersList()
    var invitePlayerTVC: InvitePlayerTVC?
    
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addPlayerButton: MyButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playersListView: UIView!
    
    var isOnlinePlayerToInvite: Bool!
    var code: String?
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            if nameTextField.isFirstResponder {
                nameTextField.resignFirstResponder()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        if isOnlinePlayerToInvite {
           addOnlinePlayer()
        } else {
            addOfflinePlayer()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap), delegate: self)
        configure(textField: nameTextField)
        popupView.layer.cornerRadius = K.windowsCornerRadius
        
        addPlayerButton.makeRounded(sound: K.sounds.click)
        addPlayerButton.disable()
        setup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInvitePlayerTVC" {
            self.invitePlayerTVC = segue.destination as? InvitePlayerTVC
            self.invitePlayerTVC?.playersList = self.playersList
            self.invitePlayerTVC?.delegate = self
        }
    }
}
// MARK: - private funcs
extension InvitePlayerVC {
    func setup() {
        playersListView?.getConstraint(named: "playersListHeight")?.constant =
            isOnlinePlayerToInvite ? 108 : 0
        titleLabel.text = isOnlinePlayerToInvite ? "Пригласить игрока онлайн" : "Добавить ещё одного игрока на этом устройстве"
    }
    
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
    private func configure(textField: UITextField) {
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        hideWarning(in: warningTextView)
        if !isOnlinePlayerToInvite {
            addPlayerButton.enable(if: textField.text!.count > 0)
            return
        }
        guard textField.text!.count > 0 else {
            self.playersList.players = []
            self.selectedPlayer = nil
            invitePlayerTVC?.tableView.reloadData()
            return
        }
        let searchRequestData = SearchRequestData(text: textField.text!.uppercased(), maxResultsQty: 10)
        UserRequest.search(with: searchRequestData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(var users):
                    users = users.filter{ $0.id != Auth().id}
                    var textIsInTheList = false
                    self?.playersList.players = users.map {
                        if $0.name.uppercased() == textField.text?.uppercased() {
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
                    self?.showWarning(error)
                }
            }
        }
    }
    func addOnlinePlayer() {
        if let player = selectedPlayer {
            delegate!.add(toGame: player,
                            successCompletion: {
                                self.dismiss(animated: true, completion: nil)
                            },
                            failedCompletion: {
                                self.showWarning("Игрок уже добавлен в игру", in: self.warningTextView)
            })
        } else {
            self.showWarning("Игрок не найден", in: warningTextView)
        }
    }
    
    func addOfflinePlayer() {
        guard let additionalName = nameTextField.text else { return }
        let joinData = JoinData(code: code!, additionalName: additionalName)
        GameRequest.join(joinData: joinData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    let player = Player(id: Auth().id!, name: additionalName, accepted: true)
                    self?.delegate?.add(toLocalData: player)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    self?.showWarning(error)
                }
            }
        }
    }
}

// MARK: - Delegates
protocol InvitePlayerVCDelegate: class {
    func select(player: Player)
}

extension InvitePlayerVC: InvitePlayerVCDelegate {
    func select(player: Player) {
        self.selectedPlayer = player
        nameTextField.text = player.name
        textFieldDidChange(nameTextField)
    }
}

extension InvitePlayerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension InvitePlayerVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view == self.view) ? true : false
    }
}
