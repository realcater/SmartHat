import Foundation

extension NewGameVC {
    func create() -> GameData {
        let settings = Settings(
            difficultyRow: picker.selectedRow(inComponent: 1),
            wordsQtyRow: picker.selectedRow(inComponent: 0),
            roundDurationRow: picker.selectedRow(inComponent: 2))
        return GameData(settings: settings, players: playersList.players)
    }
    
    func createOfflineGame() {
        game = Game(id: UUID(), data: create(), userOwner: Auth().id ?? UUID())
        playersList.saveToFile()
    }
    
    func createOnlineGame() {
        let gameData = create()
        button.disable()
        GameRequest.create(gameData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gameID):
                    self?.game = Game(id: gameID, data: gameData, userOwner: Auth().id!)
                    self?.changeModeToOnlineJoin()
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                    self?.button.enable()
                }
            }
        }
    }
    func changeModeToOnlineJoin() {
        setAcceptedStatuses()
        mode = .onlineWait
        playersTVC.playersList = playersList
        playersTVC.mode = mode
        picker.isUserInteractionEnabled = false
        playersTVC.tableView.reloadData()
        createStatusTimer()
    }
    func setAcceptedStatuses() {
        let myID = Auth().id
        playersList.players.forEach { $0.accepted = ($0.id == myID) }
    }
}
