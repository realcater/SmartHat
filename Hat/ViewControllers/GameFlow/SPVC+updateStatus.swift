import Foundation

extension StartPairVC {
    func getNewGameData() {
        GameRequest.get(gameID: gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gameData):
                    if gameData.turn != self?.gameData.turn {
                        self?.gameData = gameData
                        self?.cancelTurnTimer()
                        self?.prepareNewTurn()
                    } else if gameData.leftWords.count != self?.gameData.leftWords.count {
                        self?.gameData = gameData
                        self?.updateTitle()
                    }
                    if let timeFromExplain = gameData.timeFromExplain, self?.turnTimer == nil {
                        self?.createTurnTimer(timeLeft: gameData.settings.roundDuration-timeFromExplain )
                    }
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
    
}

// MARK: - UpdateStatusTimer
extension StartPairVC {
    @objc func updateStatusTimer() {
        getNewGameData()
    }
    
    func createStatusTimer() {
        if statusTimer == nil {
            statusTimer = Timer.scheduledTimer(timeInterval: K.Server.Time.updateGameData, target: self, selector: #selector(updateStatusTimer), userInfo: nil, repeats: true)
            statusTimer?.tolerance = 0.1
            statusTimer?.fire()
        }
    }
    
    func cancelStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
}
