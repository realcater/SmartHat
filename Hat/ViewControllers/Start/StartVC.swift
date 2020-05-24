//
//  StartViewController.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 27.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var playButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        playButton.turnClickSoundOn(sound: K.sounds.click)
        K.appSettings.load()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
