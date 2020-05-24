//settings kept in file

class AppSettings {
    let fileName = "settings"
    
    struct Data: Codable {
        var volume: Float = 1.0
    }
    var data: Data
    weak var soundDelegate: SoundsDelegate?
    
    init(soundDelegate: SoundsDelegate) {
        data = Data()
        self.soundDelegate = soundDelegate
    }
    
    func save() {
        soundDelegate?.setVolume(data.volume)
        Helper.save(data, to: fileName)
    }
    
    func load() {
        if let data: AppSettings.Data = Helper.load(from: fileName) {
            self.data = data
            soundDelegate?.setVolume(data.volume)
        }
    }
}
