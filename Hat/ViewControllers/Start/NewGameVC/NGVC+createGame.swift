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
        game = Game(id: UUID(), data: create(), userOwner: Auth().id ?? UUID(), code: nil)
        game.turn = 0
        playersList.saveToFile()
    }
    
    func createOnlineGame() {
        let gameData = create()
        button.disable()
        GameRequest.create(gameData) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gameCreated):
                    self?.game = Game(id: gameCreated.id, data: gameData, userOwner: Auth().id!, code: gameCreated.code)
                    self?.mode = .onlineCreateAfter
                case .failure(let error):
                    self?.showWarning(error)
                    self?.button.enable()
                }
            }
        }
    }
    
    func setGameStarted(completion: @escaping ()->Void) {
        game.turn = 0
        //game.data.players = playersList.players
        let frequentData = game.convertToFrequent()
        GameRequest.updateFrequent(for: game.id, frequentData: frequentData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success: completion()
                case .failure(let error): self.showWarningOrTitle(error, nil)
                }
            }
        }
    }
}
