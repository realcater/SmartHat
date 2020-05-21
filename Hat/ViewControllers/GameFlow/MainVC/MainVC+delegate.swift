import Foundation

protocol MainVCDelegate: class {
    func proceedNextTurn()
    func proceedNotNextTurn(frequentData: Game.Frequent)
    func disableGoButton()
    func printGameTurn()
    func finishGame()
    var isMyTurn: Bool { get }
    var getTitle: String? { get }
}

extension MainVC:  MainVCDelegate {
    var isMyTurn: Bool { //always true if offline game)
        return (mode == .offline) || (game.currentTeller?.id == Auth().id)
    }
    var getTitle: String? {
        return title
    }
    func proceedNextTurn() {
        cancelTurnTimer()
        if game.turn == K.endTurnNumber {
            shouldUpdateGameAtTheEnd = false
            performSegue(withIdentifier: "toEndGame", sender: self )
        } else {
            prepareNewTurn()
        }
    }
    
    func proceedNotNextTurn(frequentData: Game.Frequent) {
        if let timeFromExplain = frequentData.timeFromExplain, timeFromExplain < game.data.settings.roundDuration, turnTimer == nil {
            createTurnTimer(timeLeft: game.data.settings.roundDuration-timeFromExplain )
        }
        updateTitle()
        //if !isMyTurn { updateTitle() }
        if isMyTurn && !goButton.isEnabled { goButton.enable() }
    }
    
    func disableGoButton() {
        goButton.disable()
    }
    func printGameTurn() {
        print("StartPairVC.game=\(Unmanaged.passUnretained(game).toOpaque())")
        //print("StartPairVC.game=\(Unmanaged.passUnretained(game.data).toOpaque())")
        print("====game.turn = \(game.turn)")
    }
    
    func finishGame() {
        shouldUpdateGameAtTheEnd = false
        explainVC?.cancelTurnTimer()
        
        self.performSegue(withIdentifier: "toEndGame", sender: self)
    }
}


