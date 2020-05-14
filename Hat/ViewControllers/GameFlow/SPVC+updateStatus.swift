import Foundation

extension StartPairVC {
    func getFrequentGameData() {
        GameRequest.getFrequent(gameID: gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let frequentGameData):
                    if frequentGameData.turn != self?.gameData.turn {
                        self?.getFullGameData()
                    } else if frequentGameData.guessedThisTurn != self?.gameData.guessedThisTurn {
                        self?.gameData.guessedThisTurn = frequentGameData.guessedThisTurn
                        self?.updateTitle()
                    }
                    if let timeFromExplain = frequentGameData.timeFromExplain, timeFromExplain < self!.gameData.settings.roundDuration, self?.turnTimer == nil {
                        self?.createTurnTimer(timeLeft: self!.gameData.settings.roundDuration-timeFromExplain )
                    }
                case .failure(let error):
                    self?.showWarning(K.Server.warnings[error]!)
                }
            }
        }
    }
    func getFullGameData() {
        GameRequest.get(gameID: gameID!) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let gameData):
                    self?.gameData = gameData
                    self?.cancelTurnTimer()
                    self?.prepareNewTurn()
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
        "getFrequentGameData"
        getFrequentGameData()
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
