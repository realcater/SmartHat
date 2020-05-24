import UIKit
import SwiftKeychainWrapper

class NewUserVC: UIViewController {
    
    var name: String!
    weak var delegate: GameTypeVCDelegate?
    
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var registerButton: MyButton!
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        guard let id = UIDevice.current.identifierForVendor else {
            fatalError("Can't get UIDevice")
        }
        guard let name = textField.text else {
            showWarning("Имя не может быть пустым", in: warningTextView)
            return
        }
        guard name.count >= K.Name.minLength else {
            showWarning(K.Name.minLengthWarning, in: warningTextView)
            return
        }
        guard name.count <= K.Name.maxLength else {
            showWarning(K.Name.maxLengthWarning, in: warningTextView)
            return
        }
        let password = Helper.generatePassword()
        let user = User(id: id, name: name, password: password)
        UserRequest.create(user) { [weak self] result in
            switch result {
            case .success:
                self?.saveCredentials(id: id, name: name, password: password)
                Auth().login() { result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success:
                            self?.dismiss(animated: true, completion: nil)
                            self?.delegate?.successfullRegistration(name: name)
                        case .failure(let error):
                            self?.showWarning(K.Server.warnings[error]!, in: (self?.warningTextView)!)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.showWarning(K.Server.warnings[error]!, in: (self?.warningTextView)!)
                }
            }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.turnClickSoundOn(sound: K.sounds.click)
        self.addTaps(singleTapAction: #selector(singleTap))
        popupView.layer.cornerRadius = K.windowsCornerRadius
        textField.delegate = self
        textField.text = name
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
    }

    func saveCredentials(id: UUID, name: String, password: String) {
        KeychainWrapper.standard.set(id.uuidString, forKey: "id")
        KeychainWrapper.standard.set(name, forKey: "name")
        KeychainWrapper.standard.set(password, forKey: "password")
    }
}

extension NewUserVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        name = textField.text!
    }
}
