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
                    }
                    if let timeFromExplain = frequentGameData.timeFromExplain, timeFromExplain < self!.gameData.settings.roundDuration, self?.turnTimer == nil {
                        self?.createTurnTimer(timeLeft: self!.gameData.settings.roundDuration-timeFromExplain )
                    }
                    self?.updateTitle()
                case .failure(let error):
                    self?.showWarning(error)
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
                    if gameData.turn == K.endTurnNumber {
                        self?.performSegue(withIdentifier: "toEndGame", sender: self )
                    } else {
                        self?.prepareNewTurn()
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
    @objc func updateDataTimer() {
        getFrequentGameData()
    }
    
    func createDataTimer() {
        if dataTimer == nil {
            dataTimer = Timer.scheduledTimer(timeInterval: K.Server.Time.updateGameData, target: self, selector: #selector(updateDataTimer), userInfo: nil, repeats: true)
            dataTimer?.tolerance = 0.1
            dataTimer?.fire()
        }
    }
    func cancelDataTimer() {
        dataTimer?.invalidate()
        dataTimer = nil
    }
}
