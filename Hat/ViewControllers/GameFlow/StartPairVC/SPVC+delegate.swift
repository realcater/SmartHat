import Foundation

protocol StartPairVCDelegate: class {
    func proceedNextTurnAfterFullUpdate()
    func startTurnTimerIfNeeded(frequentData: Game.Frequent)
    func enableGoButtonIfNeeded()
    func disableGoButton()
}

extension StartPairVC:  StartPairVCDelegate {
    func proceedNextTurnAfterFullUpdate() {
        cancelTurnTimer()
        if game.turn == K.endTurnNumber {
            performSegue(withIdentifier: "toEndGame", sender: self )
        } else {
            prepareNewTurn()
        }
    }
    
    func startTurnTimerIfNeeded(frequentData: Game.Frequent) {
        if let timeFromExplain = frequentData.timeFromExplain, timeFromExplain < game.data.settings.roundDuration, turnTimer == nil {
            createTurnTimer(timeLeft: game.data.settings.roundDuration-timeFromExplain )
        }
    }
    
    func enableGoButtonIfNeeded() {
        if isMyTurn && !goButton.isEnabled { goButton.enable() }
    }
    
    func disableGoButton() {
        goButton.disable()
    }
}


