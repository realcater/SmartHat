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
    
    @IBAction func pressSaveButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = K.windowsCornerRadius
        popupView.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBasketList" {
            let basketTVC = segue.destination as? BasketTVC
            basketTVC?.game = game
        }
    }

}
