//
//  BasketVC.swift
//  Hat
//
//  Created by Dmitry Dementyev on 27.12.2019.
//  Copyright © 2019 Dmitry Dementyev. All rights reserved.
//

import UIKit

class BasketVC: UIViewController {

    @IBOutlet weak var popupView: UIView!
    
    var game: Game!
    var editable: Bool!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var saveButton: MyButton!
    @IBAction func pressSaveButton(_ sender: Any) {
        if editable { saveAndDismiss() }
    }
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            if editable { saveAndDismiss() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = K.windowsCornerRadius
        popupView.layer.masksToBounds = true
        self.addTaps(singleTapAction: #selector(singleTap))
        if !editable { saveButton.disable() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBasketList" {
            let basketTVC = segue.destination as? BasketTVC
            basketTVC?.game = game
            basketTVC?.editable = editable
            basketTVC?.delegate = self
        }
    }
    func saveAndDismiss() {
        game.basketChange += 1
        Update().fullUntilSuccess(game: game, title: "", showWarningOrTitle: self.showWarningOrTitle) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

protocol BasketVCDelegate: class {
    func showWarning()
}

extension BasketVC: BasketVCDelegate {
    func showWarning() {
        warningLabel.isHidden = false
    }
}
