import Foundation

typealias warningFunc = (_ error: RequestError?, _ title: String?) -> Void
typealias completionFunc = () -> Void

class Update {
    var stopTrying = false
    var previousIsBeingHandled = false
    var setFullTimer: Timer?
    var getFrequentTimer: Timer?
    
    var game: Game
    var title: String?
    var showWarningOrTitle: warningFunc
    weak var delegate: StartPairVCDelegate?
    
    internal init(game: Game, title: String? = nil, sender: StartPairVCDelegate, showWarningOrTitle: @escaping warningFunc) {
        self.game = game
        self.title = title
        self.showWarningOrTitle = showWarningOrTitle
        self.delegate = sender
    }
    
    func startGetFrequent(every timeInterval: Double) {
        createGetFrequentTimer(timeInterval: timeInterval)
    }
    
    func stopGetFrequent() {
        cancelGetFrequentTimer()
    }
    
    func setFrequent() {
        let frequentData = game.convertToFrequent()
        guard previousIsBeingHandled == false else { return }
        previousIsBeingHandled = true
        GameRequest.updateFrequent(for: game.id, frequentData: frequentData) { result in
            self.previousIsBeingHandled = false
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showWarningOrTitle(nil, self.title)
                case .failure(let error):
                    self.showWarningOrTitle(error, nil)
                }
                self.previousIsBeingHandled = false
            }
        }
    }
    
    func setFull(completion: completionFunc? = nil) {
        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (START) ====")
        createSetFullTimer(completion: completion)
    }
}
// MARK: - private functions
private extension Update {
    func setFullOnce(completion: completionFunc? = nil) {
        guard previousIsBeingHandled == false else { return }
        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (TRY) ====")
        previousIsBeingHandled = true
        print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = true")
        GameRequest.update(game: game) { result in
            self.previousIsBeingHandled = false
            print("\(Date().convertTo(use: "mm:ss")): previousIsBeingHandled = false")
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (SUCCESS) ====")
                        self.showWarningOrTitle(nil, self.title)
                        self.stopTrying = true
                    print("\(Date().convertTo(use: "mm:ss")): stopTrying = true")
                    case .failure(let error):
                        print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (FAILURE) ====")
                        self.showWarningOrTitle(error, nil)
                }
                if let completion = completion { completion() }
            }
        }
    }
    
    func getFrequent() {
        GameRequest.getFrequent(gameID: game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let frequentData):
                    if (frequentData.turn != self?.game.turn)  {
                        self?.getFull() {
                            self?.delegate?.proceedNextTurnAfterFullUpdate()
                        }
                    } else if frequentData.basketChange != self?.game.basketChange {
                        self?.getFull(completion: nil)
                    }
                    else if frequentData.guessedThisTurn != self?.game.guessedThisTurn {
                        self?.game.guessedThisTurn = frequentData.guessedThisTurn
                    }
                    self?.delegate?.startTurnTimerIfNeeded(frequentData: frequentData)
                    //self?.updateTitle()
                    self?.delegate?.enableGoButtonIfNeeded()
                case .failure(let error):
                    self?.showWarningOrTitle(error, nil)
                    self?.delegate?.disableGoButton()
                }
            }
        }
    }
    
    func getFull(completion: (() -> Void)?) {
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
private extension Update {
    @objc func updateSetFullTimer(completion: completionFunc? = nil) {
        if stopTrying {
            print("\(Date().convertTo(use: "mm:ss")): ==== Cancel timer ====")
            cancelSetFullTimer()
        } else {
            if !previousIsBeingHandled {
                setFullOnce()
            } else {
                print("\(Date().convertTo(use: "mm:ss")): ==== UPDATE (WAIT) ====")
            }
        }
    }
    
    func createSetFullTimer(completion: completionFunc? = nil) {
        if setFullTimer == nil {
            setFullTimer = Timer.scheduledTimer(timeInterval: K.Server.Time.waitUntilNextTry, target: self, selector: #selector(updateSetFullTimer(completion:)), userInfo: nil, repeats: true)
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
            //dataTimer?.fire()
        }
    }
    func cancelGetFrequentTimer() {
        getFrequentTimer?.invalidate()
        getFrequentTimer = nil
    }
}
