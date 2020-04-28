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
        warningTextView.isHidden = false
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
        delegate?.setNotConfirmedName(name: textField.text!)
    }
}
