//
//  AboutVC.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 03.09.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class NewUserVC: UIViewController {
    
    var name: String!
    weak var delegate: GameTypeVCDelegate?
    
    @IBOutlet weak var warningTextView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var registerButton: MyButton!
    
    @IBAction func pressRegisterButton(_ sender: Any) {
        guard let uuid = UIDevice.current.identifierForVendor else {
            fatalError("Can't get UIDevice")
        }
        guard let name = textField.text else {
            showWarning("Имя не может быть пустым")
            return
        }
        guard textField.text!.count >= K.Name.minLength else {
            showWarning(K.Name.minLengthWarning)
            return
        }
        guard textField.text!.count <= K.Name.maxLength else {
            showWarning(K.Name.maxLengthWarning)
            return
        }
        let user = User(id: uuid, name: name, password: "password")
        UserRequest().create(user) { [weak self] result in
            switch result {
            case .noConnection:
                self?.showWarning(K.Server.Warnings.noConnection)
            case .failureDuplicate:
                self?.showWarning(K.Server.Warnings.nickNameIsBusy)
            case .failureOther:
                self?.showWarning(K.Server.Warnings.serverError)
            case .success:
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                    self?.delegate?.successfullRegistration(name: name)
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
    private func showWarning(_ text: String) {
        DispatchQueue.main.async {
            self.warningTextView.text = text
            self.warningTextView.isHidden = false
        }
    }
    // MARK:- Override class func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap))
        popupView.layer.cornerRadius = K.windowsCornerRadius
        textField.delegate = self
        textField.text = name
        textField.becomeFirstResponder()
        textField.layer.borderColor = K.Colors.foreground.cgColor
        textField.layer.borderWidth = 1.0
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
