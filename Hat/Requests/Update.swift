import Foundation

typealias warningFunc = (_ error: RequestError?, _ title: String?) -> Void
typealias completionFunc = () -> Void

class Update {
    var stopTrying: Bool!
    var previousFrequentIsBeingHandled = false
    var previousFullIsBeingHandled = false
    var setFullTimer: Timer?
    var getFrequentTimer: Timer?
    
    var game: Game
    var showWarningOrTitle: warningFunc
    weak var delegate: MainVCDelegate?
    var actionAfterFullUpdate: completionFunc?
    
    internal init(game: Game, delegate: MainVCDelegate? = nil, showWarningOrTitle: @escaping warningFunc) {
        self.game = game
        print("update.game=\(Unmanaged.passUnretained(self.game).toOpaque())")
        self.showWarningOrTitle = showWarningOrTitle
        self.delegate = delegate
    }
    
    func startGetFrequent(every timeInterval: Double) {
        createGetFrequentTimer(timeInterval: timeInterval)
    }
    
    func stopGetFrequent() {
        cancelGetFrequentTimer()
    }
    
    func setFrequent() {
        print("\(Date().convertTo(use: "mm:ss")): ==== ==== UPDATE FREQUENT(START) ====")
        let frequentData = game.convertToFrequent()
        print("frequentData.guessedThisTurn=\(frequentData.guessedThisTurn)")
        GameRequest.updateFrequent(for: game.id, frequentData: frequentData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE FREQUENT(SUCCESS) ====")
                    print("frequentData.guessedThisTurn=\(frequentData.guessedThisTurn)")
                case .failure(let error):
                    if error == .gameEnded {
                        self.getFull() {
                            self.delegate?.finishGame()
                        }
                    } else {
                        self.showWarningOrTitle(error, nil)
                    }
                }
            }
        }
    }
    
    func setFull(completion: completionFunc? = nil) {
        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (START) ====")
        actionAfterFullUpdate = completion
        stopTrying = false
        createSetFullTimer()
    }
}
// MARK:             - private functions
private extension Update {
    func setFullOnce() {
        //guard previousFullIsBeingHandled == false else { return }
        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (TRY) ====")
        previousFullIsBeingHandled = true
        print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = true")
        GameRequest.update(game: game) { result in
            self.previousFullIsBeingHandled = false
            print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = false")
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (SUCCESS) ====")
                        self.stopTrying = true
                    print("\(Date().convertTo(use: "mm:ss")): stopTrying = true")
                    case .failure(let error):
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (FAILURE) ====")
                        if error == .gameEnded {
                            self.cancelGetFrequentTimer()
                            self.cancelSetFullTimer()
                            self.delegate?.finishGame()
                        } else {
                            self.showWarningOrTitle(error, nil)
                        }
                }
                if let action = self.actionAfterFullUpdate { action() }
            }
        }
    }
    
    func getFrequent() {
        print("\(Date().convertTo(use: "mm:ss")): ====GetFrequent (TRY) ====")
        
        guard previousFrequentIsBeingHandled == false else {
            print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = true")
            return
        }
        previousFrequentIsBeingHandled = true
        print("\(Date().convertTo(use: "mm:ss")): ====GetFrequent (START) ====")
        print("game.guessedThisTurn=\(game.guessedThisTurn)")
        GameRequest.getFrequent(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.previousFrequentIsBeingHandled = false
                switch result {
                case .success(let frequentData):
                    print("\(Date().convertTo(use: "mm:ss")): ====GetFrequent (SUCCESS))")
                    if (frequentData.turn != self?.game.turn)  {
                        self?.getFull() {
                            self?.delegate?.proceedNextTurn()
                        }
                    } else {
                        if frequentData.basketChange != self?.game.basketChange {
                            self?.getFull(completion: nil)
                        } else if (frequentData.guessedThisTurn != self?.game.guessedThisTurn) {
                            if self!.delegate!.isMyTurn {
                                print("===Get guessedThisTurn=\(frequentData.guessedThisTurn). OLD DATA. IGNORED")
                            } else {
                                self?.game.guessedThisTurn = frequentData.guessedThisTurn
                            }
                        }
                        self?.delegate?.proceedNotNextTurn(frequentData: frequentData)
                    }
                case .failure(let error):
                    self?.showWarningOrTitle(error, nil)
                    self?.delegate?.disableGoButton()
                }
                
            }
        }
    }
    
    func getFull(completion: (() -> Void)?) {
        print("\(Date().convertTo(use: "mm:ss")): ====GetFull (TRY) ====")
        guard previousFullIsBeingHandled == false else {
            print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = true")
            return
        }
        previousFullIsBeingHandled = true
        print("\(Date().convertTo(use: "mm:ss")): ====GetFull (START) ====")
        GameRequest.get(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                self?.previousFullIsBeingHandled = false
                switch result {
                case .success(let game):
                    print("\(Date().convertTo(use: "mm:ss")): ====GetFull (SUCCESS))")
                    self?.game.copyValues(of: game)
                    if let completion = completion { completion() }
                case .failure(let error):
                    self?.showWarningOrTitle(error, nil)
                }
            }
        }
    }

}

// MARK: - UpdateStatusTimer
private extension Update {
    @objc func updateSetFullTimer() {
        if stopTrying {
            print("\(Date().convertTo(use: "mm:ss")): ==== Cancel timer ====")
            cancelSetFullTimer()
        } else {
            if !previousFullIsBeingHandled {
                setFullOnce()
            } else {
                print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (WAIT) ====")
                print("game.guessedThisTurn=\(self.game.guessedThisTurn)")
                
            }
        }
    }
    
    func createSetFullTimer() {
        if setFullTimer == nil {
            setFullTimer = Timer.scheduledTimer(timeInterval:
                K.Server.settings.updateFullTillNextTry,
                            target: self, selector: #selector(updateSetFullTimer), userInfo: nil, repeats: true)
            setFullTimer?.tolerance = 0.1
            setFullTimer?.fire()
        }
    }
    func cancelSetFullTimer() {
        setFullTimer?.invalidate()
        setFullTimer = nil
    }
}

// MARK: - RegularTimer
private extension Update {
    @objc func updateGetFrequentTimer() {
        getFrequent()
    }
    
    func createGetFrequentTimer(timeInterval: Double) {
        if getFrequentTimer == nil {
            getFrequentTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateGetFrequentTimer), userInfo: nil, repeats: true)
            getFrequentTimer?.tolerance = 0.1
            //getFrequentTimer?.fire()
        }
    }
    func cancelGetFrequentTimer() {
        getFrequentTimer?.invalidate()
        getFrequentTimer = nil
    }
}
