import Foundation

typealias warningFunc = (_ error: RequestError?, _ title: String?) -> Void
typealias completionFunc = () -> Void

struct Update {
    var stopTrying = false
    var previousIsBeingHandled = false
    var setFullTimer: Timer?
    var getFrequentTimer: Timer?
}

// MARK: - UPDATE
extension StartPairVC {

    func startGetFrequentUpdate(every timeInterval: Double) {
        createGetFrequentTimer(timeInterval: timeInterval)
    }
    
    func stopGetFrequentUpdate() {
        cancelGetFrequentTimer()
    }
    
    
}

// MARK: - private functions
private extension StartPairVC {
    func setFullUpdateOnce(completion: completionFunc? = nil) {
        guard update.previousIsBeingHandled == false else { return }
        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (TRY) ====")
        update.previousIsBeingHandled = true
        print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = true")
        GameRequest.update(game: game) { result in
            self.update.previousIsBeingHandled = false
            print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = false")
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (SUCCESS) ====")
                        self.showWarningOrTitle(nil, self.title)
                        self.update.stopTrying = true
                    print("\(Date().convertTo(use: "mm:ss")): stopTrying = true")
                    case .failure(let error):
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (FAILURE) ====")
                        self.showWarningOrTitle(error, nil)
                }
                if let completion = completion { completion() }
            }
        }
    }
    
    func getFrequentUpdate() {
        GameRequest.getFrequent(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let frequentData):
                    if (frequentData.turn != self?.game.turn)  {
                        self?.getFullUpdate() {
                            self?.cancelTurnTimer()
                            if self?.game.turn == K.endTurnNumber {
                                self?.performSegue(withIdentifier: "toEndGame", sender: self )
                            } else {
                                self?.prepareNewTurn()
                            }
                        }
                    } else if frequentData.basketChange != self?.game.basketChange {
                        self?.getFullUpdate(completion: nil)
                    }
                    else if frequentData.guessedThisTurn != self?.game.guessedThisTurn {
                        self?.game.guessedThisTurn = frequentData.guessedThisTurn
                    }
                    if let timeFromExplain = frequentData.timeFromExplain, timeFromExplain < self!.game.data.settings.roundDuration, self?.turnTimer == nil {
                        self?.createTurnTimer(timeLeft: self!.game.data.settings.roundDuration-timeFromExplain )
                    }
                    //self?.updateTitle()
                    if self!.isMyTurn && !self!.goButton.isEnabled { self?.goButton.enable() }
                case .failure(let error):
                    self?.showWarningOrTitle(error, nil)
                    self?.goButton.disable()
                }
            }
        }
    }
    
    func getFullUpdate(completion: (() -> Void)?) {
        GameRequest.get(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let game):
                    self?.game = game
                    if let completion = completion { completion() }
                case .failure(let error):
                    self?.showWarningOrTitle(error, nil)
                }
            }
        }
    }

}

// MARK: - UpdateStatusTimer
extension StartPairVC {
    @objc func updateSetFullTimer(completion: completionFunc? = nil) {
        if update.stopTrying {
            print("\(Date().convertTo(use: "mm:ss")): ==== Cancel timer ====")
            cancelSetFullTimer()
        } else {
            if !update.previousIsBeingHandled {
                setFullUpdateOnce()
            } else {
                print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (WAIT) ====")
            }
        }
    }
    
    func createSetFullTimer(completion: completionFunc? = nil) {
        if update.setFullTimer == nil {
            update.setFullTimer = Timer.scheduledTimer(timeInterval: K.Server.Time.waitUntilNextTry, target: self, selector: #selector(updateSetFullTimer(completion:)), userInfo: nil, repeats: true)
            update.setFullTimer?.tolerance = 0.1
            update.setFullTimer?.fire()
        }
    }
    func cancelSetFullTimer() {
        update.setFullTimer?.invalidate()
        update.setFullTimer = nil
    }
}

// MARK: - RegularTimer
extension StartPairVC {
    @objc func updateGetFrequentTimer() {
        getFrequentUpdate()
    }
    
    func createGetFrequentTimer(timeInterval: Double) {
        if update.getFrequentTimer == nil {
            update.getFrequentTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateGetFrequentTimer), userInfo: nil, repeats: true)
            update.getFrequentTimer?.tolerance = 0.1
            //dataTimer?.fire()
        }
    }
    func cancelGetFrequentTimer() {
        update.getFrequentTimer?.invalidate()
        update.getFrequentTimer = nil
    }
}

