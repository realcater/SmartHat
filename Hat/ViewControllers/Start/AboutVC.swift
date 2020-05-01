//
//  AboutVC.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 03.09.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    
    //@IBOutlet weak var popView: UIView!
    @IBOutlet weak var pop4View: UIView!
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            dismiss(animated: true, completion: nil)
        }
    }
 
    // MARK:- Override class func
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTaps(singleTapAction: #selector(singleTap))
        pop4View.layer.cornerRadius = K.windowsCornerRadius
    }
}
