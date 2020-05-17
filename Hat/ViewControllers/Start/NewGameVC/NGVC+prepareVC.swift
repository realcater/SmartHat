import Foundation

extension NewGameVC {
    func preparePicker() {
        let setting = game?.data.settings ?? K.SettingsRow.start
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(setting.wordsQtyRow, inComponent: 0, animated: true)
        picker.selectRow(setting.difficultyRow, inComponent: 1, animated: true)
        picker.selectRow(setting.roundDurationRow, inComponent: 2, animated: true)
    }
    func loadPlayersList() {
        switch mode {
        case .offline:
            playersList.loadFromFile()
        case .onlineCreate:
            let me = Player(id: Auth().id, name: Auth().name!)
            playersList.players.append(me)
        default:
            playersList.players.append(contentsOf: game.data.players)
        }
    }
}
