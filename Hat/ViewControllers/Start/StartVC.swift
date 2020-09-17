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
    @IBOutlet weak var rulesButton: MyButton!
    @IBOutlet weak var aboutButton: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBackgroundImage(named: K.FileNames.background, alpha: K.Alpha.Background.main)
        playButton.makeRounded(color: K.Colors.foreground, sound: K.sounds.click)
        rulesButton.setTitleColor(K.Colors.foreground, for: .normal)
        aboutButton.setTitleColor(K.Colors.foreground, for: .normal)
        K.appSettings.load()
        navigationController?.navigationBar.tintColor = K.Colors.foreground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newGameVC = segue.destination as? NewGameVC
        newGameVC?.mode = .offline
        //tryConnectOnlineGame = false
        self.title = ""
    }
}
