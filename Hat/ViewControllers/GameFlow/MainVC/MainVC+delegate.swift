import Foundation
import UIKit

protocol MainVCDelegate: class {
    func proceedNextTurn()
    func proceedNotNextTurn(frequentData: Game.Frequent)
    func disableGoButton()
    func printGameTurn()
    func finishGame()
    func updateGuessedWord()
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
    
    func updateGuessedWord() {
        if let lastWord = game.lastWord {
            guessedWordLabel.isHidden = false
            self.guessedWordLabel.text = ""
            UIView.transition(with: guessedWordLabel,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                                self?.guessedWordLabel.text = lastWord
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.transition(with: self.guessedWordLabel,
                                      duration: 1.0,
                                      options: .transitionCrossDissolve,
                                      animations: { [weak self] in
                                        self?.guessedWordLabel.text = ""
                        }, completion: nil)
            }
        }
    }
}


