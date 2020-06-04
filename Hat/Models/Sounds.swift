import Foundation
import AVFoundation

class Sounds {
    var click = initSound(filename: "click.wav", volume: 0.05)
    var correct = initSound(filename: "true.wav", volume: 0.2)
    var error = initSound(filename: "false.wav", volume: 0.1)
    var applause = initSound(filename: "applause.wav", volume: 0.2)
    var countdown = initSound(filename: "countdown.mp3", volume: 1.0)
    var timeOver = initSound(filename: "timeOver.mp3", volume: 1.0)
    var attention = initSound(filename: "attention.wav", volume: 1.0)
    
    var _volume: Float = 1.0
    var volume: Float {
        get { return _volume }
        set {
            let value = max(min(newValue,1.0),0.0001)
            click?.volume = click!.volume * value / _volume
            correct?.volume = correct!.volume * value / _volume
            error?.volume = error!.volume * value / _volume
            applause?.volume = applause!.volume * value / _volume
            countdown?.volume = countdown!.volume * value / _volume
            timeOver?.volume = timeOver!.volume * value / _volume
            attention?.volume = attention!.volume * value / _volume
            _volume = value
        }
    }
}

protocol SoundsDelegate: class {
    func setVolume(_ volume: Float)
}

extension Sounds: SoundsDelegate {
    func setVolume(_ volume: Float) {
        self.volume = volume
    }
}
