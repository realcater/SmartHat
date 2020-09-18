
import Foundation

extension NewGameVC {
    func requestUpdatePlayerStatus() {
        GameRequest.getPlayersStatus(gameID: self.game.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let statusBeforeStart):
                    self?.update(from: statusBeforeStart)
                case .failure(let error):
                    self?.showWarning(error)
                    if error == .noConnection { self?.makeMeNotInGame() }
                }
            }
        }
    }
    
    func update(from statusBeforeStart: StatusBeforeStart) {
        var anythingChanged = false
        if statusBeforeStart.turn >= 0 {
            game.turn = statusBeforeStart.turn
            performSegue(withIdentifier: "toMain", sender: self)
            return
        }
        let a = playersList.players == statusBeforeStart.players
        print("Равны?: \(a)")
        print("playersList.players=\(playersList.players.map {$0.id})")
        print("statusBeforeStart.players=\(statusBeforeStart.players.map {$0.id})")
        
        if statusBeforeStart.players.count != playersList.players.count {
            anythingChanged = true
        } else {
            anythingChanged = zip(statusBeforeStart.players, playersList.players)
                .map {
                    $0.id == $1.id && $0.accepted == $1.accepted && $0.inGame == $1.inGame
            }.contains(false)
        }
        if anythingChanged {
            playersList.players = statusBeforeStart.players
            game.data.players = statusBeforeStart.players
            checkMeInList()
            playersTVC?.tableView.reloadData()
            if mode == .onlineCreateAfter {
                button.enable(if: everyPlayerReady)
            }
        }
    }
    
    var everyPlayerReady: Bool {
        guard playersList.players.count >= K.minPlayersQty else { return false }
        return !playersList.players.map{ $0.accepted }.contains(false)
    }
    func makeMeNotInGame() {
        let myID = Auth().id
        if let player = playersList.players.first(where: { $0.id == myID }) {
            player.lastTimeInGame = Date(timeIntervalSince1970: 0).convertTo()
        }
        playersTVC.tableView.reloadData()
    }
    func checkMeInList() {
        let myID = Auth().id
        if !playersList.players.map({$0.id == myID}).contains(true) {
            //cancelStatusTimer()
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - Timer
extension NewGameVC {
    @objc func updateStatusTimer() {
        requestUpdatePlayerStatus()
    }
    
    func createStatusTimer() {
        if statusTimer == nil {
            statusTimer = Timer.scheduledTimer(timeInterval: K.Server.settings.updatePlayersStatus, target: self, selector: #selector(updateStatusTimer), userInfo: nil, repeats: true)
            statusTimer?.tolerance = 0.1
            statusTimer?.fire()
        }
    }
    
    func cancelStatusTimer() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
}
