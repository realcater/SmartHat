import UIKit
import SwiftKeychainWrapper

class SettingsVC: UIViewController {
    
    var name: String!
    weak var createJoinVCDelegate: CreateJoinVCDelegate?
    
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var saveButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.turnClickSoundOn(sound: K.sounds.click)
        self.addTaps(singleTapAction: #selector(singleTap), delegate: self)
        popupView.layer.cornerRadius = K.windowsCornerRadius
        textField.delegate = self
        textField.text = name
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
        textField.autocorrectionType = .no
        textField.text = Auth().name
        volumeSlider.value = K.sounds.volume
        volumeSlider.isContinuous = false
    }

    func updateCredentials(newName: String) {
        KeychainWrapper.standard.set(newName, forKey: "name")
    }
}

// MARK: - events handlers
extension SettingsVC {
    @IBAction func volumeSliderChanged(_ sender: Any) {
        K.appSettings.data.volume = volumeSlider.value
        K.appSettings.save()
        K.sounds.click?.play()
    }
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        guard let _ = UIDevice.current.identifierForVendor else {
            fatalError("Can't get UIDevice")
        }
        guard let newName = textField.text else {
            showWarning("Имя не может быть пустым", in: warningTextView)
            return
        }
        guard newName.count >= K.Name.minLength else {
            showWarning(K.Name.minLengthWarning, in: warningTextView)
            return
        }
        guard newName.count <= K.Name.maxLength else {
            showWarning(K.Name.maxLengthWarning, in: warningTextView)
            return
        }
        let updateUserData = UpdateUserData(newName: newName)
        
        guard newName != Auth().name else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        UserRequest.changeName(updateUserData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success:
                    self?.updateCredentials(newName: updateUserData.newName)
                    self?.createJoinVCDelegate?.update(title: newName)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        self?.showWarning(K.Server.warnings[error]!, in: (self?.warningTextView)!)
                    }
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
}

// MARK: - UITextFieldDelegate
extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        name = textField.text!
    }
}

extension SettingsVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view == self.view) ? true : false
    }
}
