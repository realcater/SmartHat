//
//  MyButton+extension.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 30.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import UIKit
import AVFoundation

class MyButton: UIButton {
    var sound: AVAudioPlayer? = nil

    @objc func playClickSound(_ sender: MyButton) {
        sound?.play()
    }
    func makeRounded(color: UIColor? = nil, textColor: UIColor? = nil, sound: AVAudioPlayer? = nil) {
        self.layer.cornerRadius = 0.5 * self.bounds.size.height
        if let color = color { self.backgroundColor = color }
        if let textColor = textColor { self.setTitleColor(textColor, for: .normal) }
        if let sound = sound { self.turnClickSoundOn(sound: sound) }
        
    }
    func turnClickSoundOn(sound: AVAudioPlayer?) {
        self.addTarget(self, action: #selector(playClickSound), for: .touchDown)
        self.sound = sound
    }
    func show(color: UIColor, title: String, sound: AVAudioPlayer? = nil) {
        self.setTitle(title, for: .normal)
        backgroundColor = color
        isHidden = false
        if let sound = sound {
            turnClickSoundOn(sound: sound)
        } else {
            self.removeTarget(nil, action: nil, for: .touchDown)
        }
    }
}
