//
//  DescriptionsVC.swift
//  Hat
//
//  Created by Realcater on 18.09.2020.
//  Copyright © 2020 Dmitry Dementyev. All rights reserved.
//

import UIKit

class DescriptionsVC: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    var words: [Word]!
    var currentWordNumber = 0
    
    @objc private func singleTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) {
            next()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        popupView.layer.cornerRadius = K.windowsCornerRadius
        popupView.layer.masksToBounds = true
        self.addTaps(singleTapAction: #selector(singleTap))
        updateLabels()
    }
    
    func next() {
        currentWordNumber+=1
        if currentWordNumber == words.count {
            dismiss(animated: true, completion: nil)
        } else {
            updateLabels()
        }
    }
    
    func updateLabels() {
        wordLabel.text = words[currentWordNumber].text
        descriptionLabel.text = words[currentWordNumber].description
    }

}
