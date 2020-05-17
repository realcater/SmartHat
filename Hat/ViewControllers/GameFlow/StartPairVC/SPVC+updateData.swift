import Foundation

extension StartPairVC {
    func getFrequentGameData() {
        GameRequest.getFrequent(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let frequentData):
                    if frequentData.turn != self?.game.turn {
                        self?.getFullGameData()
                    } else if frequentData.guessedThisTurn != self?.game.guessedThisTurn {
                        self?.game.guessedThisTurn = frequentData.guessedThisTurn
                    }
                    if let timeFromExplain = frequentData.timeFromExplain, timeFromExplain < self!.game.data.settings.roundDuration, self?.turnTimer == nil {
                        self?.createTurnTimer(timeLeft: self!.game.data.settings.roundDuration-timeFromExplain )
                    }
                    self?.updateTitle()
                case .failure(let error):
                    self?.showWarning(error)
                }
            }
        }
    }
    func getFullGameData() {
        GameRequest.get(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let game):
                    self?.game = game
                    self?.cancelTurnTimer()
                    if game.turn == K.endTurnNumber {
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
